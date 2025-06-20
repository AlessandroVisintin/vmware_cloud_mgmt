function Get-Index {
    param (
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerRequest]$Request,
        
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerResponse]$Response
    )
    
    # $servicesContent = ""
    # foreach ($service in $services) { 

    #     $params = @{
    #         "viewPath" = "Utils/ServiceCard.html"
    #         "viewData" = @{
    #             "CardTitle" = $service[0]
    #             "CardDescription" = $service[1]
    #             "CardUrl" = $service[2]
    #         }
    #     }
    #     $servicesContent += (Render-View @params)

    # }

    # $params = @{
    #     "viewPath" = "Index.html"
    #     "viewData" = @{
    #         "ServiceCards" = $servicesContent
    #     }
    # }
    # $mainContent = Render-View @params

    $Response.ContentType = "text/html"

    $serviceCardView = Get-Content (Join-Path $script:ViewsPath "Utils/ServiceCard.html") -Raw
    $serviceGridView = Get-Content (Join-Path $script:ViewsPath "Utils/ServiceGrid.html") -Raw
    $layoutView = Get-Content (Join-Path $script:ViewsPath "Layout.html") -Raw

    $viewData = $global:TextContent.layout
    $viewData.psobject.Properties |
        ForEach-Object { $layoutView = $layoutView -replace "{{$($_.Name)}}", $_.Value }

    $viewData = $global:TextContent.pages.index
    $viewData.psobject.Properties |
        ForEach-Object { $layoutView = $layoutView -replace "{{$($_.Name)}}", $_.Value }
    
    $serviceGridView = $serviceGridView -replace "{{ServiceGridIntro}}", $viewData.ServiceGridIntro

    $serviceCards = ""
    $viewData.Services.GetEnumerator() |
        ForEach-Object { 
            $serviceCard = $serviceCardView
            $_.psobject.Properties |
                ForEach-Object { $serviceCard = $serviceCard -replace "{{$($_.Name)}}", $_.Value }
            $serviceCards += $serviceCard
        }
    
    $serviceGridView = $serviceGridView -replace "{{ServiceCards}}", $serviceCards
    $layoutView = $layoutView -replace "{{MainContent}}", $serviceGridView 
    return $layoutView
}