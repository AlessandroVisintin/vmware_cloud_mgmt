param (
    [string]$Mode = "Logger"
)

$Private = @(Get-ChildItem -Path "$PSScriptRoot\Private" -Filter "*.ps1" -Recurse)

foreach ($file in $Private) {
    . $file.FullName
}

if ($Mode -eq "Logger") {
    $Script:LogPath = "$($env:USERPROFILE)\Logs"
    $Script:LogName = "requestsLog.txt"
    $Script:LogFilePath = Join-Path -Path $Script:LogPath -ChildPath $Script:LogName
    if (-not (Test-Path -Path $Script:LogFilePath)) {
        New-Item -Path $Script:LogFilePath -ItemType File -Force
    }
    $Public = @(Get-ChildItem -Path "$PSScriptRoot\Public\Logger" -Filter "*.ps1" -Recurse)
} elseif ($Mode -eq "Mocker") {
    $Script:DataRoot = Join-Path -Path $PSScriptRoot -ChildPath "Data"
    $Public = @(Get-ChildItem -Path "$PSScriptRoot\Public\Mocker" -Filter "*.ps1" -Recurse)
} else {
    throw "Unsupported Mode $Mode"
}

foreach ($file in $Public) {
    . $file.FullName
}