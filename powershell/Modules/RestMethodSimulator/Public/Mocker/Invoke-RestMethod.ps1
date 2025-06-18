function Invoke-RestMethod {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [uri]$Uri,
        [Parameter(Mandatory = $true, Position = 1)]
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method,
        [Parameter(ValueFromPipeline)]
        [object]$Body,
        [System.Collections.IDictionary]$Headers,
        [Parameter(ValueFromRemainingArguments=$true)]
        $RemainingParameters
    )

    if ($Uri -like "file://*") {
        $response = Get-MockResponse -Uri $Uri -Method $Method -Headers $Headers -Body $Body
        if ($response.ContentType -eq 'application/json') {
            return $response.Content | ConvertFrom-Json
        } elseif ($response.ContentType -eq 'application/xml') {
            return [xml]$response.Content
        }
        return $response.Content
    }
    else {
        $cmdletParams = Convert-ArgsToSplattable -Arguments $RemainingParameters
        $cmdletParams['Uri'] = $Uri
        $cmdletParams['Method'] = $Method
        $cmdletParams['Body'] = $Body
        $cmdletParams['Headers'] = $Headers
        return Microsoft.PowerShell.Utility\Invoke-RestMethod @cmdletParams
    }
}
