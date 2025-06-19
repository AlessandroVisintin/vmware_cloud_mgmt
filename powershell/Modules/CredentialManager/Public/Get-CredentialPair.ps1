function Get-CredentialPair {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Label,
        [Parameter(Mandatory=$false)]
        [bool]$Prompt=$false
    )
    
    $filePath = Join-Path -Path $script:CredentialStore -ChildPath "$Label$script:CredentialFileExtension"
    
    if (-not (Test-Path -Path $filePath)) {
        if (-not $Prompt) {
            Write-Verbose "Credential pair not found for label: $Label"
            return $null
        }
        Save-CredentialPair -Label $Label
    }
    
    $credential = Import-Clixml -Path $filePath
    return $credential

}