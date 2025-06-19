@{
    RootModule = 'PSHttpServer.psm1'
    ModuleVersion = '0.1.0'
    GUID = '77e96eae-f3f6-47fe-ac5a-fc7c466269b0'
    Author = 'Alessandro Visintin'
    CompanyName = 'COSMOS @ DIGIT'
    Description = 'PowerShell module for creating local web servers using the MVC pattern'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Start-WebServer',
        'Stop-WebServer',
        'New-Controller',
        'New-Model',
        'New-View',
        'New-Route',
        'Initialize-MVCApplication',
        'Get-MvcRoutes'
    )
    VariablesToExport = @(
        'AppRoot',
        'ViewsPath',
        'ControllersPath',
        'ModelsPath',
        'StaticFilesPath'
    )
}
