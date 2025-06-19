function Get-VSVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Address   
    )

    $response = Invoke-WebRequest -Uri "$Address/sdk/vimServiceVersions.xml" -Method Get -UseBasicParsing
    [xml]$data = $response.Content

    $vim25Namespace = $data.SelectSingleNode("//namespace[name='urn:vim25']")
    if ($null -eq $vim25Namespace) { throw "Unable to find vim25 namespace in vimServiceVersions.xml" }

    $version = $vim25Namespace.SelectSingleNode("version").InnerText
    if ($null -eq $version) { throw "Cannot retrieve version from vimServiceVersions.xml" }

    return $version
}