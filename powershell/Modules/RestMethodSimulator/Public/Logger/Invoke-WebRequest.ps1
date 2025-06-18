function Invoke-WebRequest {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $RemainingParameters
    )

    $wrappedCmd = Get-Command -Name Microsoft.PowerShell.Utility\Invoke-WebRequest -CommandType Cmdlet
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
        
        $response = & $wrappedCmd @params # Execute the original cmdlet
        
        $responseLog = "[$timestamp] RESPONSE: Status $($response.StatusCode) $($response.StatusDescription)`n"
        $responseLog += "Headers: $($response.Headers | ConvertTo-Json -Compress)`n"
        $responseLog += "Content:`n$($response.Content)`n"
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