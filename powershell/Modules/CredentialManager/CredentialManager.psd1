@{
    RootModule = 'CredentialManager.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'f5a9ce56-3d48-4d61-b677-98a93c148fe2'
    Author = 'Alessandro Visintin'
    CompanyName = 'COSMOS @ DIGIT'
    Description = 'Module for securely managing usernames and passwords using SecureString'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Get-CredentialPair',
        'Remove-CredentialPair',
        'Update-CredentialPair',
        'Save-CredentialPair'
    )
}
