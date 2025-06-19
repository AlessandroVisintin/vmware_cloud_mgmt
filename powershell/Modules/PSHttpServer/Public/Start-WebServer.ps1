function Start-WebServer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$Url = "http://localhost:8080/",
        
        [Parameter(Mandatory=$true)]
        [string]$AppPath,
        
        [Parameter(Mandatory=$false)]
        [switch]$NoRouteRegistration
    )
    
    begin {
        # Validate application path
        if (-not (Test-Path -Path $AppPath)) {
            throw "Application path does not exist: $AppPath"
        }
        
        # Set global paths
        $script:AppRoot = (Resolve-Path $AppPath).Path
        $script:ViewsPath = Join-Path -Path $script:AppRoot -ChildPath "Views"
        $script:ControllersPath = Join-Path -Path $script:AppRoot -ChildPath "Controllers"
        $script:ModelsPath = Join-Path -Path $script:AppRoot -ChildPath "Models"
        $script:StaticFilesPath = Join-Path -Path $script:AppRoot -ChildPath "wwwroot"
        
        # Create HTTP listener
        $script:WebServerListener = New-Object System.Net.HttpListener
        $script:WebServerListener.Prefixes.Add($Url)
    }
    
    process {
        try {
            # Start the listener
            $script:WebServerListener.Start()
            Write-Host "Web server started at $Url" -ForegroundColor Green
            Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
            
            # Register routes if not disabled
            if (-not $NoRouteRegistration) {
                Register-AllRoutes
            }
            
            # Main request handling loop
            while ($script:WebServerListener.IsListening) {
                $contextTask = $script:WebServerListener.GetContextAsync()
                
                # Wait for the next request in 200ms increments to allow for graceful stopping
                while (-not $contextTask.AsyncWaitHandle.WaitOne(200)) { }
                
                $context = $contextTask.GetAwaiter().GetResult()
                
                try {
                    Invoke-RequestHandler -Context $context
                }
                catch {
                    Write-Host "Error handling request: $_"
                    $response = $context.Response
                    $response.StatusCode = 500
                    $errorMessage = "Internal Server Error: $_"
                    $buffer = [System.Text.Encoding]::UTF8.GetBytes($errorMessage)
                    $response.ContentLength64 = $buffer.Length
                    $response.OutputStream.Write($buffer, 0, $buffer.Length)
                    $response.OutputStream.Close()
                }
            }
        }
        catch {
            Write-Error "Error in web server: $_"
        }
        finally {
            # Ensure the server is stopped if we exit the loop
            if ($script:WebServerListener -ne $null) {
                $script:WebServerListener.Stop()
                $script:WebServerListener.Close()
                $script:WebServerListener = $null
                Write-Host "Web server stopped" -ForegroundColor Green
            }
        }
    }
}
