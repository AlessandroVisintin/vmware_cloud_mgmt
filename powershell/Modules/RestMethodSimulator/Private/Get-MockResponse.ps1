function Get-MockResponse {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Uri,
        [Parameter(Mandatory = $true)]
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method,
        [System.Collections.IDictionary]$Headers,
        [object]$Body
    )
    
    $localPath = Join-Path $Script:DataRoot (Convert-UriToLocalPath -Uri $Uri)
    $methodFile = $null

    $methodFile = Join-Path $localPath "$Method.ps1"
    if (-not (Test-Path $methodFile)) {
        $methodFile = "$localPath.$Method.ps1"
        if (-not (Test-Path $methodFile)) {
            $errorLog = @{ 'error' = "$uri not found" }
            return @{
                Content = ($errorLog | ConvertTo-Json)
                StatusCode = 404
                ContentType = 'application/json'
            }
        }
    }

    $parsedBody = $Body
    if ($Body -is [string] -and $Body.Trim().StartsWith("{")) {
        try {
            $parsedBody = $Body | ConvertFrom-Json
        } catch {
        }
    }

    $context = @{
        ScriptRoot = Split-Path $methodFile -Parent
        Method = $Method
        Headers = $Headers
        Body = $parsedBody
        RawBody = $Body
        Uri = $Uri
        Query = Get-UriQueryParameters $Uri

        ThrowError = {
            param(
                [int]$Code,
                [string]$Message
            )
            throw "$Code::$Message"
        }
    }

    try {
        $scriptBlock = [ScriptBlock]::Create((Get-Content -Path $methodFile -Raw))
        $result = & $scriptBlock $context
        return $result
    }
    catch {
        if ($_ -match '(\d{3})::(.+)') {
            return @{
                Content = @{ error = $matches[2] } | ConvertTo-Json -Compress
                StatusCode = [int]$matches[1]
                ContentType = 'application/json'
            }
        }
        return @{
            Content = @{ error = "Unhandled exception: $_" } | ConvertTo-Json -Compress
            StatusCode = 500
            ContentType = 'application/json'
        }
    }

}
