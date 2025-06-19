class VCenterAlarmProvider {
    [object] $vimConnection
    [object] $vsConnection
    [hashtable] $cache
    
    VCenterAlarmProvider([object] $vimConnection, [object] $vsConnection) {
        $this.vimConnection = $vimConnection
        $this.vsConnection = $vsConnection
        $this.cache = @{}
    }

    hidden [pscustomobject] getAlarmInfo([string] $alarmMoId) {
        if (-not $this.cache.ContainsKey($alarmMoId)) {
            $this.cache[$alarmMoId] = $this.vimConnection.getAlarmInfo($alarmMoId)
        }
        return $this.cache[$alarmMoId]
    }

    hidden [pscustomobject] getAlarmEntity([string] $entityType, [string] $entityMoId) {
        if (-not $this.cache.ContainsKey($entityMoId)) {
            $this.cache[$entityMoId] = $this.vsConnection.getEntity($entityType, $entityMoId)
        }
        return $this.cache[$entityMoId]
    }
    
    [array] getTriggeredAlarmState() {
        $alarms = $this.vimConnection.getTriggeredAlarmState()
        foreach ($alarm in $alarms) {
            $params = @{
                MemberType = "NoteProperty"
                Name = "extensionData"
                Value = $this.getAlarmInfo($alarm.alarm.value)
            }
            $alarm.alarm | Add-Member @params
            $params.Value = $this.getAlarmEntity($alarm.entity.type, $alarm.entity.value)
            $alarm.entity | Add-Member @params
        }
        $modeledAlarms = $alarms | ForEach-Object {
            [pscustomobject]@{
                Name = $_.alarm.extensionData.name
                Resource = $_.entity.value.ToLower()
                Timestamp = $_.Time
                Message = $_.alarm.extensionData.description
                RawData = $_
            }
        }
        return $modeledAlarms
    }
}
