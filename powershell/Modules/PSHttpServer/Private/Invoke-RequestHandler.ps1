function Invoke-RequestHandler {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerContext]$Context
    )
    
    $request = $Context.Request
    $response = $Context.Response
    
    # Log the request
    Write-Host "$($request.HttpMethod) $($request.Url.PathAndQuery) - $($request.UserHostAddress)" -ForegroundColor Cyan
    
    $path = $request.Url.AbsolutePath
    $method = $request.HttpMethod
    
    # Check if it's a static file request
    if (Test-StaticFileRequest -Path $path) {
        Serve-StaticFile -Path $path -Response $response
        return
    }
    
    # Look for matching route
    $routeKey = "${method}:${path}"
    if ($script:Routes.ContainsKey($routeKey)) {
        $routeHandler = $script:Routes[$routeKey]
        
        # Execute the route handler
        $result = & $routeHandler -Request $request -Response $response
        
        # If the handler returned a result, write it to the response
        if ($result -ne $null -and -not $response.OutputStream.IsClosed) {
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($result)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.OutputStream.Close()
        }
    }
    else {
        # No matching route found, return 404
        $response.StatusCode = 404
        $notFoundMessage = "<h1>404 - Not Found</h1><p>The requested resource was not found: $path</p>"
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($notFoundMessage)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.OutputStream.Close()
    }
}

function Test-StaticFileRequest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    # Check if the path points to a static file
    $filePath = Join-Path -Path $script:StaticFilesPath -ChildPath $Path.TrimStart('/')
    return (Test-Path -Path $filePath -PathType Leaf)
}

function Serve-StaticFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerResponse]$Response
    )
    
    $filePath = Join-Path -Path $script:StaticFilesPath -ChildPath $Path.TrimStart('/')
    
    try {
        if ($PSVersionTable.PSVersion.Major -ge 6) {
            $content = Get-Content -Path $filePath -Raw -AsByteStream            
        } else {
            $content = Get-Content -Path $filePath -Raw -Encoding Byte
        }
        $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
        
        # Set content type based on file extension
        $contentType = switch ($extension) {
            ".html" { "text/html" }
            ".css"  { "text/css" }
            ".js"   { "application/javascript" }
            ".json" { "application/json" }
            ".png"  { "image/png" }
            ".jpg"  { "image/jpeg" }
            ".jpeg" { "image/jpeg" }
            ".gif"  { "image/gif" }
            ".svg"  { "image/svg+xml" }
            ".ico"  { "image/x-icon" }
            default { "application/octet-stream" }
        }
        
        $Response.ContentType = $contentType
        $Response.ContentLength64 = $content.Length
        $Response.OutputStream.Write($content, 0, $content.Length)
    }
    catch {
        $Response.StatusCode = 500
        $errorMessage = "<h1>500 - Internal Server Error</h1><p>Error serving static file: $_</p>"
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($errorMessage)
        $Response.ContentLength64 = $buffer.Length
        $Response.OutputStream.Write($buffer, 0, $buffer.Length)
    }
    finally {
        $Response.OutputStream.Close()
    }
}
