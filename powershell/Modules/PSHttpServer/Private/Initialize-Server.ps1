if (-not (Get-Variable -Name SessionStore -Scope Script -ErrorAction SilentlyContinue)) {
    $script:SessionStore = @{}
}

function Get-SessionId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerRequest]$Request,
        
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerResponse]$Response
    )
    
    $sessionCookieName = "PSWebMVC_SessionId"
    $sessionId = $null
    
    if ($Request.Cookies[$sessionCookieName]) {
        $sessionId = $Request.Cookies[$sessionCookieName].Value
        Write-Verbose "Retrieved existing session ID: $sessionId"
    }
    
    if (-not $sessionId) {
        $sessionId = [Guid]::NewGuid().ToString()
        Write-Verbose "Created new session ID: $sessionId"
        $cookie = New-Object System.Net.Cookie
        $cookie.Name = $sessionCookieName
        $cookie.Value = $sessionId
        $cookie.Path = "/"
        $Response.Cookies.Add($cookie)
    }
    
    return $sessionId
}

function Get-SessionItem {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SessionId,
        
        [Parameter(Mandatory=$true)]
        [string]$Key
    )
    
    if ($script:SessionStore.ContainsKey($SessionId) -and 
        $script:SessionStore[$SessionId].ContainsKey($Key)) {
        return $script:SessionStore[$SessionId][$Key]
    }
    return $null
}

function Set-SessionItem {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SessionId,
        
        [Parameter(Mandatory=$true)]
        [string]$Key,
        
        [Parameter(Mandatory=$true)]
        [object]$Value
    )
    
    if (-not $script:SessionStore.ContainsKey($SessionId)) {
        $script:SessionStore[$SessionId] = @{}
    }
    
    $script:SessionStore[$SessionId][$Key] = $Value
}

function Remove-SessionItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$SessionId,
        
        [Parameter(Mandatory=$true)]
        [string]$Key
    )
    
    if ($script:SessionStore.ContainsKey($SessionId) -and 
        $script:SessionStore[$SessionId].ContainsKey($Key)) {
        $script:SessionStore[$SessionId].Remove($Key)
        return $true
    }
    return $false
}

function Clear-Session {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$SessionId
    )
    
    if ($script:SessionStore.ContainsKey($SessionId)) {
        $script:SessionStore.Remove($SessionId)
        return $true
    }
    return $false
}
