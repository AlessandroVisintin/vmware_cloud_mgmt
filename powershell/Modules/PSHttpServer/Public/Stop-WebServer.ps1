function Stop-WebServer {
    [CmdletBinding()]
    param()
    
    process {
        if ($script:WebServerListener -ne $null -and $script:WebServerListener.IsListening) {
            $script:WebServerListener.Stop()
            $script:WebServerListener.Close()
            $script:WebServerListener = $null
            Write-Host "Web server stopped" -ForegroundColor Green
        }
        else {
            Write-Warning "No web server is currently running"
        }
    }
}
