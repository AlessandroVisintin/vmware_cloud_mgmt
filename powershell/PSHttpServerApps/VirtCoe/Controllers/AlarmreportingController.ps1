 function Get-Alarmreporting {
    param (
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerRequest]$Request,
        
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerResponse]$Response
    )

    $Response.ContentType = "text/html"

    $twoColumnView = Get-Content (Join-Path $script:ViewsPath "Utils/TwoColumnContainer.html") -Raw
    $layoutView = Get-Content (Join-Path $script:ViewsPath "Layout.html") -Raw

    $viewData = $global:TextContent.layout
    $viewData.psobject.Properties |
        ForEach-Object { $layoutView = $layoutView -replace "{{$($_.Name)}}", $_.Value }

    $viewData = $global:TextContent.pages.alarmreporting
    $viewData.psobject.Properties |
        ForEach-Object { $layoutView = $layoutView -replace "{{$($_.Name)}}", $_.Value }

    $layoutView = $layoutView -replace "{{MainContent}}", $twoColumnView 
    return $layoutView

}
