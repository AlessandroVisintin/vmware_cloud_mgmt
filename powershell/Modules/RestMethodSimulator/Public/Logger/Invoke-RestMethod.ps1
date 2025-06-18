function Invoke-RestMethod {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $RemainingParameters
    )

    $wrappedCmd = Get-Command -Name Microsoft.PowerShell.Utility\Invoke-RestMethod -CommandType Cmdlet
    $params = Convert-ArgsToSplattable -Arguments $RemainingParameters
    
    try {
        $uri = if ($params.ContainsKey('Uri')) { $params['Uri'] } else { "Unknown URI" }
        $method = if ($params.ContainsKey('Method')) { $params['Method'] } else { "Unknown METHOD" }
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "[$timestamp] REQUEST: $method $uri`n"
        if ($params.ContainsKey('Headers')) {
            $logMessage += "Headers: $($params['Headers'] | ConvertTo-Json -Compress)`n"
        }
        if ($params.ContainsKey('Body')) {
            $logMessage += "Body: $($params['Body'])`n"
        }
        $logMessage | Out-File -FilePath $Script:LogFilePath -Append
        $responseHeaders = @{}
        $params['ResponseHeadersVariable'] = 'responseHeaders'
        
        $response = & $wrappedCmd @params

        $responseLog = "[$timestamp] RESPONSE: Status $($responseHeaders.StatusCode) $($responseHeaders.StatusDescription)`n"
        $responseLog += "Headers: $($responseHeaders | ConvertTo-Json -Compress)`n"
        $rawContent = ""
        if ($response -ne $null) {
            if ($response -is [string]) {
                $rawContent = $response
            }
            elseif ($response -is [System.Xml.XmlDocument]) {
                $rawContent = $response.OuterXml
            }
            elseif ($response -is [PSObject] -or $response -is [Array]) {
                $rawContent = $response | ConvertTo-Json -Depth 10
            }
            else {
                $rawContent = "Content type: $($response.GetType().FullName)`n$response"
            }
        }
        $responseLog += "Content:`n$rawContent`n"
        $responseLog += "======== END OF RESPONSE ========`n"
        $responseLog | Out-File -FilePath $Script:LogFilePath -Append
        return $response
    } catch {
        $errorLog = "[$timestamp] ERROR: $_`n"
        $errorLog += "======== END OF RESPONSE ========`n"
        $errorLog | Out-File -FilePath $Script:LogFilePath -Append
        throw
    }
}
