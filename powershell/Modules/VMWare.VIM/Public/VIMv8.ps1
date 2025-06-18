class VIMv8 {
    [string]$baseUrl = $null
    [string]$authToken = $null
    [hashtable]$authHeaders = $null

    VIMv8([string]$Address, [PSCredential]$Credential) {
        try {
            $this.baseUrl = "$Address/sdk/vim25/8.0.1.0"
            $sessionManagerMoid = Get-VIMMoId -BaseUrl $this.baseUrl -MoId "sessionManager"
            $body = @{
                userName = $Credential.UserName
                password = $Credential.GetNetworkCredential().Password
            } | ConvertTo-Json
            $params = @{
                Uri = "$($this.baseUrl)/SessionManager/$sessionManagerMoid/Login"
                Method = "POST"
                Body = $body
                ContentType = "application/json"
            }
            $response = Invoke-WebRequest @params
            $this.authToken = $response.Headers.'vmware-api-session-id'[0]
            $this.authHeaders = @{
                'vmware-api-session-id' = $this.authToken
                'Content-Type' = 'application/json'
            }
        }
        finally {
            if ($body) {
                $body = $null
                Remove-Variable -Name body -ErrorAction SilentlyContinue
            }
            [System.GC]::Collect()
        }
    }

    [pscustomobject] getTriggeredAlarmState() {
        $datacenter = $this.getDatacenter()
        $datacenterMoid = $datacenter.value
        $uri = "$($this.baseUrl)/Datacenter/$datacenterMoid/triggeredAlarmState"
        return Invoke-RestMethod -Uri $uri -Method Get -Headers $this.authHeaders
    }

    hidden [pscustomobject] createCollectorForEvents(
        [Nullable[datetime]]$beginTime = $null,
        [Nullable[datetime]]$endTime = $null,
        [array]$eventTypeId=@()
        ) {
        
        $eventFilterSpecByTime = @{ _typeName = "EventFilterSpecByTime" }
        if ($null -ne $beginTime) { $eventFilterSpecByTime.beginTime = $beginTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ") }
        if ($null -ne $endTime) { $eventFilterSpecByTime.endTime = $endTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ") }

        $body = @{
            filter = @{
                _typeName   = "EventFilterSpec"
                time = $eventFilterSpecByTime
                eventTypeId = $eventTypeId
            }
        }
        $eventManagerMoid = Get-VIMMoId -BaseUrl $this.baseUrl -MoId "EventManager"
        $uri = "$($this.baseUrl)/EventManager/$eventManagerMoid/CreateCollectorForEvents"
        return Invoke-RestMethod -Uri $uri -Method Post -Headers $this.authHeaders -Body ($body | ConvertTo-Json -Depth 5)
    }

    hidden [void] destroyCollector([object]$collectorMoRef) {
        $uri = "$($this.baseUrl)/EventHistoryCollector/$($collectorMoRef.value)/DestroyCollector"
        Invoke-RestMethod -Uri $uri -Method Post -Headers $this.authHeaders
    }

    [pscustomobject] getAlarmEventsHistory() {
        $eventTypeId = @("AlarmCreatedEvent", "AlarmStatusChangedEvent", "AlarmAcknowledgedEvent", "AlarmActionTriggeredEvent", "AlarmClearedEvent")
        $collectorMoRef = $this.createCollectorForEvents($null, $null, $eventTypeId)
        $events = @()
        $body = @{ maxCount = 1000 }
        $uri = "$($this.baseUrl)/EventHistoryCollector/$($collectorMoRef.value)/ReadNextEvents"
        try {
            while ($true) {
                $nextEvents = Invoke-RestMethod -Uri $uri -Method Post -Headers $this.authHeaders -Body ($body | ConvertTo-Json -Depth 5)
                $events += $nextEvents
                if ( $nextEvents.count -eq 0 ) {
                    break
                }
            }
        }
        finally {
            $this.destroyCollector($collectorMoRef)
        }
        return $events
    }

    [pscustomobject] getAlarmInfo([string]$AlarmMoId) {
        $uri = "$($this.baseUrl)/Alarm/$AlarmMoId/info"
        return Invoke-RestMethod -Uri $uri -Method Get -Headers $this.authHeaders
    }

    [pscustomobject] getDatacenter() {
        $rootFolderMoid = Get-VIMMoId -BaseUrl $this.baseUrl -MoId "rootFolder"
        $uri = "$($this.baseUrl)/Folder/$rootFolderMoid/childEntity"
        return Invoke-RestMethod -Uri $uri -Method Get -Headers $this.authHeaders
    }

    [pscustomobject] getSession() {
        $sessionManagerMoid = Get-VIMMoId -BaseUrl $this.baseUrl -MoId "sessionManager"
        $uri = "$($this.baseUrl)/SessionManager/$sessionManagerMoid/currentSession"
        $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $this.authHeaders
        if ($response) {
            return $response
        }
        return $null
    }

    [void] disconnect() {
        $sessionManagerMoid = Get-VIMMoId -BaseUrl $this.baseUrl -MoId "sessionManager"
        $uri = "$($this.BaseUrl)/SessionManager/$sessionManagerMoid/Logout"
        $null = Invoke-RestMethod -Uri $uri -Method Post -Headers $this.authHeaders
    }

}