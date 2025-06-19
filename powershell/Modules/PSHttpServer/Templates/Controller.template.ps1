function Get-Index {
    param (
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerRequest]$Request,
        
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerResponse]$Response
    )
    
    # Get the view content
    $viewPath = Join-Path -Path $script:ViewsPath -ChildPath "{{ControllerName}}\Index.html"
    $viewContent = Get-Content -Path $viewPath -Raw
    
    # Get the layout
    $layoutPath = Join-Path -Path $script:ViewsPath -ChildPath "Shared\_Layout.html"
    $layoutContent = Get-Content -Path $layoutPath -Raw
    
    # Replace placeholders in the view
    $viewContent = $viewContent -replace '{{Message}}', 'Hello from {{ControllerName}}!'
    
    # Insert view into layout
    $pageContent = $layoutContent -replace '{{Content}}', $viewContent -replace '{{PageTitle}}', '{{ControllerName}}'
    
    # Set response properties
    $Response.ContentType = "text/html"
    
    return $pageContent
}
