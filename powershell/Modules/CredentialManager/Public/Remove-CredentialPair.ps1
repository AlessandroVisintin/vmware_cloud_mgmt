function Remove-CredentialPair {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Label
    )
    
    $filePath = Join-Path -Path $script:CredentialStore -ChildPath "$Label$script:CredentialFileExtension"    
    
    if (-not (Test-Path -Path $filePath)) {
        Write-Verbose "Credential pair not found for label: $Label"
        return
    }
    
    if ($PSCmdlet.ShouldProcess("Credential pair: $Label", "Remove")) {
        Remove-Item -Path $filePath -Force
        Write-Verbose "Credential pair removed: $Label"
    }
}