[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Public = @(Get-ChildItem -Path "$PSScriptRoot\Public" -Filter "*.ps1" -Recurse)
$Private = @(Get-ChildItem -Path "$PSScriptRoot\Private" -Filter "*.ps1" -Recurse)

foreach ($file in $Private) {
    . $file.FullName
}

foreach ($file in $Public) {
    . $file.FullName
}
