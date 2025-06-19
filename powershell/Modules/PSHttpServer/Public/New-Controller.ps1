function New-Controller {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name
    )
    
    begin {
        if (-not $Name.EndsWith("Controller")) {
            $Name = "${Name}Controller"
        }
        
        $controllerPath = Join-Path -Path $script:ControllersPath -ChildPath "$Name.ps1"
        
        # Check if controller already exists
        if (Test-Path -Path $controllerPath) {
            throw "Controller already exists: $controllerPath"
        }
    }
    
    process {
        # Ensure Controllers directory exists
        if (-not (Test-Path -Path $script:ControllersPath)) {
            New-Item -Path $script:ControllersPath -ItemType Directory -Force | Out-Null
        }
        
        # Get template content
        $templatePath = Join-Path -Path $PSScriptRoot -ChildPath "../../Templates/Controller.template.ps1"
        $templateContent = Get-Content -Path $templatePath -Raw
        
        # Replace placeholders
        $controllerContent = $templateContent -replace '{{ControllerName}}', $Name
        
        # Create controller file
        Set-Content -Path $controllerPath -Value $controllerContent
        
        Write-Host "Created controller: $controllerPath" -ForegroundColor Green
        return $controllerPath
    }
}
