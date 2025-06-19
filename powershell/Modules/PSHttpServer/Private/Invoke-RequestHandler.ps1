# Enhanced Invoke-RequestHandler function
function Invoke-RequestHandler {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerContext]$Context
    )
    
    $request = $Context.Request
    $response = $Context.Response
    
    try {
        # Thread-safe request processing
        $requestPath = $request.Url.AbsolutePath.TrimEnd('/')
        if ($requestPath -eq '') { $requestPath = '/' }
        
        $method = $request.HttpMethod.ToUpper()
        $routeKey = "$method$requestPath"
        
        # Check for static files first (thread-safe)
        if (Test-StaticFileRequest -Path $requestPath) {
            Serve-StaticFile -Path $requestPath -Response $response
            return
        }
        
        # Handle dynamic routes
        if ($script:Routes.ContainsKey($routeKey)) {
            $handler = $script:Routes[$routeKey]
            $result = & $handler -Request $request -Response $response
            
            if ($result -ne $null -and -not $response.OutputStream.IsClosed) {
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($result)
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
                $response.OutputStream.Close()
            }
        } else {
            # 404 Not Found
            $response.StatusCode = 404
            $notFoundMessage = "<h1>404 - Not Found</h1><p>The requested resource was not found: $requestPath</p>"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($notFoundMessage)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.OutputStream.Close()
        }
    }
    catch {
        # Error handling
        if (-not $response.OutputStream.IsClosed) {
            $response.StatusCode = 500
            $errorMessage = "<h1>500 - Internal Server Error</h1><p>An error occurred processing your request.</p>"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($errorMessage)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.OutputStream.Close()
        }
        throw
    }
}
