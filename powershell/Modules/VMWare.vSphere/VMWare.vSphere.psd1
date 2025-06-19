@{
    RootModule = 'VMware.vSphere.psm1'
    ModuleVersion = '0.1.0'
    GUID = 'bd6f2fe7-949b-4ce7-8945-63ef9fdce5ca'
    Author = 'Alessandro Visintin'
    CompanyName = 'COSMOS @ DIGIT'
    Description = 'PowerShell module for interacting with VMware vSphere REST API'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Connect-VS',
        'Disconnect-VS',
        'Test-VSConnection',
        'Get-VSHosts'
    )
}
