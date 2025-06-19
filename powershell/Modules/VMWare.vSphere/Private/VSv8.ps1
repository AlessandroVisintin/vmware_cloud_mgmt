class VSv8 {
    [string]$baseUrl = $null
    [string]$authToken = $null
    [hashtable]$authHeaders = $null

    VSv8([string]$Address, [PSCredential]$Credential) {
        try {
            $this.baseUrl = "$Address/rest"
            $sessionUrl = "$($this.baseUrl)/com/vmware/cis/session"
            $authString = "$($Credential.UserName):$($Credential.GetNetworkCredential().Password)"
            $base64Auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($authString))
            $headers = @{
                "Authorization" = "Basic $base64Auth"
                "Content-Type"  = "application/json"
            }
            $response = Invoke-RestMethod -Uri $sessionUrl -Method Post -Headers $headers
            $this.authToken = $response.value
            $this.authHeaders = @{
                "vmware-api-session-id" = $this.authToken
                "Content-Type" = "application/json"
            }
        }
        finally {
            $authString = $null
            $base64Auth = $null
            Remove-Variable -Name authString -ErrorAction SilentlyContinue
            Remove-Variable -Name base64Auth -ErrorAction SilentlyContinue
            [System.GC]::Collect()
        }
    }

    [pscustomobject] getEntity([string]$entityType, [string]$entityMoId) {
        switch ($entityType) {
            "VirtualMachine" { return $this.getVM($entityMoId) }
            "HostSystem" { return $this.getHost($entityMoId) }
            default { return {} }
        }
        return {}
    }

    [pscustomobject] getHosts() {
        $url = "$($this.BaseUrl)/vcenter/host"
        return Invoke-RestMethod -Uri $url -Method Get -Headers $this.authHeaders
    }

    [pscustomobject] getHost([string]$hostMoId) {
        $url = "$($this.BaseUrl)/vcenter/host?filter.hosts.1=$hostMoId"
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $this.authHeaders
        if ($response.value) {
            return ($response.value)[0]
        }
        return {}
    }

    [pscustomobject] getVMs() {
        $url = "$($this.BaseUrl)/vcenter/vm"
        return Invoke-RestMethod -Uri $url -Method Get -Headers $this.authHeaders
    }

    [pscustomobject] getVM([string]$vmMoId) {
        $url = "$($this.BaseUrl)/vcenter/vm/$vmMoId"
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $this.authHeaders 
        if ($response.value) {
            return $response.value 
        }
        return {}
    }

    [bool] testConnection() {
        try {
            $testUrl = "$($this.BaseUrl)/vcenter/vm"
            $null = Invoke-RestMethod -Uri $testUrl -Method Get -Headers $this.authHeaders
            return $true
        }
        catch {
            return $false
        }
    }

    [void] disconnect() {
        $url = "$($this.BaseUrl)/com/vmware/cis/session"    
        $null = Invoke-RestMethod -Uri $url -Method Delete -Headers $this.authHeaders
    }

}