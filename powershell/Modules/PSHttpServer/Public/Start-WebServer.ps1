# Enhanced Start-WebServer.ps1
function Start-WebServer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Url = "http://localhost:8080/",
        
        [Parameter(Mandatory=$true)]
        [string]$AppPath,
        
        [Parameter(Mandatory=$false)]
        [switch]$NoRouteRegistration,
        
        [Parameter(Mandatory=$false)]
        [int]$MaxConcurrentRequests = 10,
        
        [Parameter(Mandatory=$false)]
        [int]$RequestTimeoutSeconds = 30
    )
    
    begin {
        # Initialize runspace pool for multithreading
        $script:RunspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxConcurrentRequests)
        $script:RunspacePool.Open()
        $script:ActiveJobs = @{}
        $script:RequestCounter = 0
        
        # Store module functions in session state for runspaces
        $InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        
        # Add module functions to session state
        $ModuleFunctions = Get-Command -Module PSHttpServer
        foreach ($Function in $ModuleFunctions) {
            $FunctionDefinition = "function $($Function.Name) { $($Function.Definition) }"
            $InitialSessionState.Commands.Add([System.Management.Automation.Runspaces.SessionStateFunctionEntry]::new($Function.Name, $FunctionDefinition))
        }
        
        $script:RunspacePool.InitialSessionState = $InitialSessionState
    }
    
    process {
        # Set up paths and routes (existing logic)
        $script:AppPath = Resolve-Path $AppPath
        $script:ControllersPath = Join-Path -Path $script:AppPath -ChildPath "Controllers"
        $script:ViewsPath = Join-Path -Path $script:AppPath -ChildPath "Views"
        $script:StaticFilesPath = Join-Path -Path $script:AppPath -ChildPath "wwwroot"
        
        if (-not $NoRouteRegistration) {
            Register-AllRoutes
        }
        
        # Create and start HTTP listener
        $script:WebServerListener = New-Object System.Net.HttpListener
        $script:WebServerListener.Prefixes.Add($Url)
        $script:WebServerListener.Start()
        
        Write-Host "Multithreaded web server started at $Url" -ForegroundColor Green
        Write-Host "Max concurrent requests: $MaxConcurrentRequests" -ForegroundColor Cyan
        Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
        
        try {
            while ($script:WebServerListener.IsListening) {
                # Clean up completed jobs
                Remove-CompletedJobs
                
                # Get context asynchronously with timeout
                $contextTask = $script:WebServerListener.GetContextAsync()
                
                # Wait for request with periodic cleanup
                while (-not $contextTask.AsyncWaitHandle.WaitOne(1000)) {
                    Remove-CompletedJobs
                    
                    # Check if we should continue listening
                    if (-not $script:WebServerListener.IsListening) {
                        break
                    }
                }
                
                if ($contextTask.IsCompleted) {
                    $context = $contextTask.GetAwaiter().GetResult()
                    
                    # Create new runspace job for request handling
                    $RequestId = ++$script:RequestCounter
                    $PowerShell = [powershell]::Create()
                    $PowerShell.RunspacePool = $script:RunspacePool
                    
                    # Add request handling script
                    $null = $PowerShell.AddScript({
                        param($Context, $RequestId, $AppPath, $ControllersPath, $ViewsPath, $StaticFilesPath, $Routes, $TimeoutSeconds)
                        
                        try {
                            # Set script-level variables for the runspace
                            $script:AppPath = $AppPath
                            $script:ControllersPath = $ControllersPath
                            $script:ViewsPath = $ViewsPath
                            $script:StaticFilesPath = $StaticFilesPath
                            $script:Routes = $Routes
                            
                            # Set timeout for long-running requests
                            $TimeoutTimer = [System.Diagnostics.Stopwatch]::StartNew()
                            
                            # Process the request
                            Invoke-RequestHandler -Context $Context
                            
                            return @{
                                RequestId = $RequestId
                                Status = "Success"
                                ProcessingTime = $TimeoutTimer.ElapsedMilliseconds
                            }
                        }
                        catch {
                            # Handle errors gracefully
                            try {
                                $response = $Context.Response
                                $response.StatusCode = 500
                                $errorMessage = "Internal Server Error"
                                $buffer = [System.Text.Encoding]::UTF8.GetBytes($errorMessage)
                                $response.ContentLength64 = $buffer.Length
                                $response.OutputStream.Write($buffer, 0, $buffer.Length)
                                $response.OutputStream.Close()
                            }
                            catch {
                                # If we can't send error response, just log it
                                Write-Error "Failed to send error response: $_"
                            }
                            
                            return @{
                                RequestId = $RequestId
                                Status = "Error"
                                Error = $_.Exception.Message
                            }
                        }
                    })
                    
                    # Add parameters
                    $null = $PowerShell.AddParameters(@{
                        Context = $context
                        RequestId = $RequestId
                        AppPath = $script:AppPath
                        ControllersPath = $script:ControllersPath
                        ViewsPath = $script:ViewsPath
                        StaticFilesPath = $script:StaticFilesPath
                        Routes = $script:Routes
                        TimeoutSeconds = $RequestTimeoutSeconds
                    })
                    
                    # Start async execution
                    $AsyncResult = $PowerShell.BeginInvoke()
                    
                    # Store job info
                    $script:ActiveJobs[$RequestId] = @{
                        PowerShell = $PowerShell
                        AsyncResult = $AsyncResult
                        StartTime = Get-Date
                        Context = $context
                    }
                    
                    Write-Verbose "Started request $RequestId on thread pool"
                }
            }
        }
        catch {
            Write-Error "Error in web server: $_"
        }
        finally {
            # Clean up all active jobs
            Stop-AllJobs
            
            if ($script:WebServerListener -ne $null) {
                $script:WebServerListener.Stop()
                $script:WebServerListener.Close()
                $script:WebServerListener = $null
            }
            
            if ($script:RunspacePool -ne $null) {
                $script:RunspacePool.Close()
                $script:RunspacePool.Dispose()
                $script:RunspacePool = $null
            }
            
            Write-Host "Multithreaded web server stopped" -ForegroundColor Green
        }
    }
}

# Helper function to clean up completed jobs
function Remove-CompletedJobs {
    $CompletedJobs = @()
    
    foreach ($JobId in $script:ActiveJobs.Keys) {
        $Job = $script:ActiveJobs[$JobId]
        
        if ($Job.AsyncResult.IsCompleted) {
            try {
                # Get the result
                $Result = $Job.PowerShell.EndInvoke($Job.AsyncResult)
                
                if ($Result -and $Result.Status -eq "Error") {
                    Write-Warning "Request $JobId failed: $($Result.Error)"
                } else {
                    Write-Verbose "Request $JobId completed successfully in $($Result.ProcessingTime)ms"
                }
            }
            catch {
                Write-Warning "Error completing job $JobId : $_"
            }
            finally {
                # Clean up PowerShell instance
                $Job.PowerShell.Dispose()
                $CompletedJobs += $JobId
            }
        }
        elseif (((Get-Date) - $Job.StartTime).TotalSeconds -gt 30) {
            # Handle timeout
            Write-Warning "Request $JobId timed out, cleaning up"
            try {
                $Job.PowerShell.Stop()
                $Job.PowerShell.Dispose()
                
                # Send timeout response if possible
                if ($Job.Context.Response -and -not $Job.Context.Response.OutputStream.IsClosed) {
                    $Job.Context.Response.StatusCode = 408
                    $timeoutMessage = "Request Timeout"
                    $buffer = [System.Text.Encoding]::UTF8.GetBytes($timeoutMessage)
                    $Job.Context.Response.ContentLength64 = $buffer.Length
                    $Job.Context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
                    $Job.Context.Response.OutputStream.Close()
                }
            }
            catch {
                Write-Warning "Error cleaning up timed out job $JobId : $_"
            }
            
            $CompletedJobs += $JobId
        }
    }
    
    # Remove completed jobs from active list
    foreach ($JobId in $CompletedJobs) {
        $script:ActiveJobs.Remove($JobId)
    }
}

# Helper function to stop all active jobs
function Stop-AllJobs {
    foreach ($JobId in $script:ActiveJobs.Keys) {
        $Job = $script:ActiveJobs[$JobId]
        try {
            if (-not $Job.AsyncResult.IsCompleted) {
                $Job.PowerShell.Stop()
            }
            $Job.PowerShell.Dispose()
        }
        catch {
            Write-Warning "Error stopping job $JobId : $_"
        }
    }
    $script:ActiveJobs.Clear()
}
