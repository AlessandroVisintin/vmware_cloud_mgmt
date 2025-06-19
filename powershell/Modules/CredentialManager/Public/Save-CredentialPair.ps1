function Save-CredentialPair {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Label,        
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$Credential
    )

    if (-not (Test-Path -Path $script:CredentialStore)) {
        New-Item -Path $script:CredentialStore -ItemType Directory -Force | Out-Null
        Write-Verbose "Created credential store directory: $script:CredentialStore"
    }

    if (-not $Credential) {
        $Credential = Get-Credential -Message "Enter credentials for $Label"
        if (-not $Credential) {
            Write-Verbose "No credentials provided for $Label"
            return
        }
    }
    
    $filePath = Join-Path -Path $script:CredentialStore -ChildPath "$Label$script:CredentialFileExtension"
    $Credential | Export-Clixml -Path $filePath -Force
    Write-Verbose "Credential pair saved as $Label"
}