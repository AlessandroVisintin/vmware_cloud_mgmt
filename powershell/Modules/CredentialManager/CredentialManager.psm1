## IMPORTANT
# For extra-security, credential store is inside the current user folder
$script:CredentialStore = "$env:USERPROFILE\CredentialStore"
$script:CredentialFileExtension = ".cred"

$Public = @(Get-ChildItem -Path "$PSScriptRoot\Public" -Filter "*.ps1" -Recurse)
$Private = @(Get-ChildItem -Path "$PSScriptRoot\Private" -Filter "*.ps1" -Recurse)

# Import all private functions
foreach ($file in $Private) {
    . $file.FullName
}

# Import and export all public functions
foreach ($file in $Public) {
    . $file.FullName
}