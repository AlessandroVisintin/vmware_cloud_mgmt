function Convert-UriToLocalPath {
    param([string]$Uri)

    $httpUri = $Uri -replace '^file://', 'http://'
    $decodedUri = [System.Uri]::UnescapeDataString($httpUri)
    $uriObj = [System.Uri]::new($decodedUri)
    $path = "$($uriObj.Host)$($uriObj.Segments -join '')"
    $path = $path -replace '/', [System.IO.Path]::DirectorySeparatorChar
    return $path
}