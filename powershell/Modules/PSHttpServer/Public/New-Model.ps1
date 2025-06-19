function New-Model {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$Properties = @{}
    )
    
    begin {
        $modelPath = Join-Path -Path $script:ModelsPath -ChildPath "$Name.ps1"
        
        # Check if model already exists
        if (Test-Path -Path $modelPath) {
            throw "Model already exists: $modelPath"
        }
    }
    
    process {
        # Ensure Models directory exists
        if (-not (Test-Path -Path $script:ModelsPath)) {
            New-Item -Path $script:ModelsPath -ItemType Directory -Force | Out-Null
        }
        
        # Get template content
        $templatePath = Join-Path -Path $PSScriptRoot -ChildPath "../../Templates/Model.template.ps1"
        $templateContent = Get-Content -Path $templatePath -Raw
        
        # Build properties script
        $propertiesScript = ""
        foreach ($prop in $Properties.GetEnumerator()) {
            $propType = if ($prop.Value) { "[$($prop.Value)]" } else { "" }
            $propertiesScript += "    ${propType}`$$($prop.Key)`n"
        }
        
        # Replace placeholders
        $modelContent = $templateContent -replace '{{ModelName}}', $Name -replace '{{Properties}}', $propertiesScript
        
        # Create model file
        Set-Content -Path $modelPath -Value $modelContent
        
        Write-Host "Created model: $modelPath" -ForegroundColor Green
        return $modelPath
    }
}
