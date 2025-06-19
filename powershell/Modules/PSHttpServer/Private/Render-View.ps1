# Private/Utils/Render-ViewWithLayout.ps1
function Render-View {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$ViewPath,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$ViewData = @{}
    )

    $ViewPath = Join-Path -Path $script:ViewsPath -ChildPath $ViewPath
    $ViewContent = Get-Content -Path $ViewPath -Raw    
    foreach ($key in $ViewData.Keys) {
        $placeholder = "{{$key}}"
        $viewContent = $viewContent -replace $placeholder, $ViewData[$key]
    }
    return $viewContent
}
