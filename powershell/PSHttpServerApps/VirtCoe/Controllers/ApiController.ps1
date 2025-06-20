function Get-ApiVcenterendpoints {
    param (
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerRequest]$Request,
        
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerResponse]$Response
    )

    try {
        $responseObj = @{
            status = 200
            results = $global:VCenterEndpoints
            message = "Found $($global:VCenterEndpoints.Count) vCenter endpoints"
        }
    }
    catch {
        $responseObj = @{
            status = 500
            results = @()
            message = $_.Exception.Message
        }
    }

    $Response.ContentType = "application/json"
    return ($responseObj | ConvertTo-Json)
}

function Post-ApiVcentertriggeredalarms {
    param (
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerRequest]$Request,
        
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerResponse]$Response
    )

    try {
        $reader = New-Object System.IO.StreamReader($Request.InputStream, $Request.ContentEncoding)
        $requestBody = $reader.ReadToEnd()
        $reader.Close()

        $data = $requestBody | ConvertFrom-Json
        $endpoint = $data.endpoint

        $credential = $global:vSphereClientCredential
        $vimClient = Connect-VIM -Server $endpoint -Credential $credential
        $vsphereClient = Connect-VS -Server $endpoint -Credential $credential

        $alarmProvider = New-VCenterAlarmProvider -vimConnection $vimClient -vsConnection $vsphereClient
        $triggeredAlarms = $alarmProvider.getTriggeredAlarmState()
        $responseObj = @{
            status = 200
            results = $triggeredAlarms
            message = "Found $($triggeredAlarms.Count) triggered alarms"
        }
    }
    catch {
        $responseObj = @{
            status = 500
            results = @()
            message = $_.Exception.Message
        }
    }

    $Response.ContentType = "application/json"
    return ($responseObj | ConvertTo-Json)
}