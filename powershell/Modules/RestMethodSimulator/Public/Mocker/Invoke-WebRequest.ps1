function Invoke-WebRequest {
    [CmdletBinding(DefaultParameterSetName = 'StandardMethod')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [uri]$Uri,
        [Parameter(Mandatory = $true, Position = 1)]
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method,
        [Parameter(ValueFromPipeline)]
        [object]$Body,
        [System.Collections.IDictionary]$Headers,
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArgs
    )
    
    if ($Uri -like "file://*") {
        $response = Get-MockResponse -Uri $Uri -Method $Method -Headers $Headers -Body $Body
        return $response
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
