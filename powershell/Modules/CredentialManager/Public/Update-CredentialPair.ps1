function Update-CredentialPair {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Label,    
        [Parameter(Mandatory=$false)]
        [string]$NewUsername,
        [Parameter(Mandatory=$false)]
        [System.Security.SecureString]$NewPassword
    )
    
    if (-not (Test-CredentialPair -Label $Label)) {
        Write-Verbose "Credential pair not found for label: $Label"
        return
    }
    
    $credential = Get-CredentialPair -Label $Label
    
    if ($NewUsername -and $NewPassword) {
        $updatedCredential = New-Object System.Management.Automation.PSCredential($NewUsername, $NewPassword)
    }
    elseif ($NewUsername) {
        $updatedCredential = New-Object System.Management.Automation.PSCredential($NewUsername, $credential.Password)
    }
    elseif ($NewPassword) {
        $updatedCredential = New-Object System.Management.Automation.PSCredential($credential.UserName, $NewPassword)
    }
    else {
        Write-Verbose "No changes specified for credential update"
        return
    }
    
    Save-CredentialPair -Label $Label -Credential $updatedCredential
    Write-Verbose "Credential pair updated: $Label"
}