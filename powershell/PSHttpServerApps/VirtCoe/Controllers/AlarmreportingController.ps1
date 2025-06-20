function Get-Alarmreporting {
    param (
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerRequest]$Request,
        
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerResponse]$Response
    )

    $Response.ContentType = "text/html"

    $layoutView = Get-Content (Join-Path $script:ViewsPath "Layout.html") -Raw

    $viewData = $global:TextContent.layout
    $viewData.psobject.Properties |
        ForEach-Object { $layoutView = $layoutView -replace "{{$($_.Name)}}", $_.Value }

    $viewData = $global:TextContent.pages.alarmreporting
    $viewData.psobject.Properties |
        ForEach-Object { $layoutView = $layoutView -replace "{{$($_.Name)}}", $_.Value }

    # $mainContent = ""
    # $viewData.Services.GetEnumerator() |
    # ForEach-Object { 
    #     $serviceCard = $serviceCardView
    #     $_.psobject.Properties |
    #     ForEach-Object { $serviceCard = $serviceCard -replace "{{$($_.Name)}}", $_.Value }
    #     $mainContent += $serviceCard
    # }
    # $indexView = $indexView -replace "{{MainContent}}", $mainContent 
    return $layoutView

}


# function Get-VCenterEndpoints {
#     param (
#         [Parameter(Mandatory=$true)]
#         [System.Net.HttpListenerRequest]$Request,
        
#         [Parameter(Mandatory=$true)]
#         [System.Net.HttpListenerResponse]$Response
#     )

#     $reader = New-Object System.IO.StreamReader(
#         $Request.InputStream,
#         $Request.ContentEncoding
#     )
#     $requestBody = $reader.ReadToEnd()
#     $reader.Close()

#     $jsonRequest = $requestBody | ConvertFrom-Json


#     $Response.ContentType = "application/json"
    
#     $orderReference = $searchData.orderReference
#     try {
#         $results = $global:CROCDatabase.getC3DSBVMWAREServers($orderReference)
#         $responseObj = @{
#             success = $true
#             results = $results
#             message = "Found $($results.Count) hosts for order reference: $orderReference"
#         }

#         $sessionId = Get-SessionId -Request $Request -Response $Response
#         Set-SessionItem -SessionId $sessionId -Key "OrderReference" -Value $orderReference
#         Set-SessionItem -SessionId $sessionId -Key $orderReference -Value $results

#     }
#     catch {
#         $responseObj = @{
#             success = $false
#             results = @()
#             message = "Error: $($_.Exception.Message)"
#         }
#     }
    
#     return ($responseObj | ConvertTo-Json)
# }