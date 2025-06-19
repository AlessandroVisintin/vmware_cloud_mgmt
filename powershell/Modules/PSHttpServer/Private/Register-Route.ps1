function Register-Route {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Method,
        
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [Parameter(Mandatory=$true)]
        [scriptblock]$Handler
    )
    
    $routeKey = "${Method}:${Path}"
    $script:Routes[$routeKey] = $Handler
    Write-Host "Registered route: $Method $Path" -ForegroundColor Green
}

function Register-AllRoutes {
    [CmdletBinding()]
    param()
    
    # Clear existing routes
    $script:Routes = @{}
    
    # Load all controller files
    $controllers = Get-ChildItem -Path $script:ControllersPath -Filter "*.ps1" -Recurse
    
    foreach ($controller in $controllers) {
        try {
            # Source the controller file to make its functions available
            . $controller.FullName
            
            # Look for route definitions in the controller
            # Convention: functions named like "Get-Home", "Post-Login", etc.
            $functions = Get-ChildItem -Path "Function:\*" | Where-Object { 
                $_.Name -match "^(Get|Post|Put|Delete)-" -and 
                $_.ScriptBlock.File -eq $controller.FullName 
            }
            
            foreach ($function in $functions) {
                $parts = $function.Name -split "-", 2
                $method = $parts[0]
                $routeName = $parts[1]
                
                # Convert route name to path (e.g., "UserProfile" to "/user-profile")
                $routePath = "/" + ($routeName -csplit '(?<=.)(?=[A-Z])' -join '-').ToLower()

                # Write-Host $method $routeName $routePath
                Register-Route -Method $method -Path $routePath -Handler $function.ScriptBlock
                if ($routePath -eq '/index') { # Special case for root path
                    Register-Route -Method $method -Path '/' -Handler $function.ScriptBlock
                }  
            }
        }
        catch {
            Write-Error "Failed to register routes from controller $($controller.Name): $_"
        }
    }
}
