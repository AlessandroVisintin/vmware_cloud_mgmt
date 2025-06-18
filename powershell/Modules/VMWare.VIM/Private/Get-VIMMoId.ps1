function Get-VIMMoId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$BaseUrl,
        [Parameter(Mandatory = $false)]
        [string]$MoId
    )

    $params = @{
        Uri = "$BaseUrl/ServiceInstance/ServiceInstance/content"
        Method = "Get"
    }
    $serviceInstance = Invoke-RestMethod @params
    return $serviceInstance.$MoId.value
}
