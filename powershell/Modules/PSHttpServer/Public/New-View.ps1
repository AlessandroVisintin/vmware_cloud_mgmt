function New-View {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        
        [Parameter(Mandatory=$false)]
        [string]$Controller = "Home"
    )
    
    begin {
        # Ensure Controller name is standardized
        if (-not $Controller.EndsWith("Controller")) {
            $Controller = "${Controller}Controller"
        }
        
        # Create path for the view
        $controllerViewsPath = Join-Path -Path $script:ViewsPath -ChildPath $Controller.Replace("Controller", "")
        $viewPath = Join-Path -Path $controllerViewsPath -ChildPath "$Name.html"
        
        # Check if view already exists
        if (Test-Path -Path $viewPath) {
            throw "View already exists: $viewPath"
        }
    }
    
    process {
        # Ensure view directories exist
        if (-not (Test-Path -Path $script:ViewsPath)) {
            New-Item -Path $script:ViewsPath -ItemType Directory -Force | Out-Null
        }
        
        if (-not (Test-Path -Path $controllerViewsPath)) {
            New-Item -Path $controllerViewsPath -ItemType Directory -Force | Out-Null
        }
        
        # Get template content
        $templatePath = Join-Path -Path $PSScriptRoot -ChildPath "../../Templates/View.template.html"
        $templateContent = Get-Content -Path $templatePath -Raw
        
        # Replace placeholders
        $viewContent = $templateContent -replace '{{ViewName}}', $Name -replace '{{Controller}}', $Controller.Replace("Controller", "")
        
        # Create view file
        Set-Content -Path $viewPath -Value $viewContent
        
        Write-Host "Created view: $viewPath" -ForegroundColor Green
        return $viewPath
    }
}
