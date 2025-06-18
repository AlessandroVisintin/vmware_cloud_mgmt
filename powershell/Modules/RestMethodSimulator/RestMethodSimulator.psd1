@{
    RootModule = 'RestMethodSimulator.psm1'
    ModuleVersion = '0.1.0'
    GUID = '38e87c5d-c891-4225-ab8f-4bd143ff6e43'
    Author = 'Alessandro Visintin'
    CompanyName = 'COSMOS @ DIGIT'
    Description = 'Provides various mocking methods for Invoke-RestMethod and Invoke-WebRequest calls without modifying application code'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Invoke-RestMethod',
        'Invoke-WebRequest'
    )
}
