function Get-UriQueryParameters {
    param([string]$Uri)

    $httpUri = $Uri -replace '^file://', 'http://'
    $decodedUri = [System.Uri]::UnescapeDataString($httpUri)
    $uriObj = [System.Uri]::new($decodedUri)
    if (-not $uriObj.Query) {
        return @{}
    }
    $queryString = $uriObj.Query
    if ($queryString.StartsWith("?")) {
        $queryString = $queryString.Substring(1)
    }
    $query = @{}
    foreach ($pair in $queryString -split "&") {
        if ($pair -match "=") {
            $key, $value = $pair -split "=", 2
            $query[$key] = $value
        }
        elseif ($pair) {
            $query[$key] = $null
        }
    }
    return $query
}