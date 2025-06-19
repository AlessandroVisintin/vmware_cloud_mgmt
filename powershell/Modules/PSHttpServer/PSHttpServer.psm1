$Public = @(Get-ChildItem -Path "$PSScriptRoot\Public" -Filter "*.ps1" -Recurse)
$Private = @(Get-ChildItem -Path "$PSScriptRoot\Private" -Filter "*.ps1" -Recurse)

# Import all private functions
foreach ($file in $Private) {
    . $file.FullName
}

# Import and export all public functions
foreach ($file in $Public) {
    . $file.FullName
    Export-ModuleMember -Function $file.BaseName
}

# Initialize module-level variables
$script:WebServerListener = $null
$script:Routes = @{}
$script:AppRoot = ""
$script:ViewsPath = ""
$script:ControllersPath = ""
$script:ModelsPath = ""
$script:StaticFilesPath = ""

# Export module-level variables
Export-ModuleMember -Variable AppRoot, ViewsPath, ControllersPath, ModelsPath, StaticFilesPath
