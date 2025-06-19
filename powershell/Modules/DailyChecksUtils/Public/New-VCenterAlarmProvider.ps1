function New-VCenterAlarmProvider {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object] $vimConnection,
        [Parameter(Mandatory = $true)]
        [object] $vsConnection
    )
    
    return [VCenterAlarmProvider]::new(
        $vimConnection,
        $vsConnection
    )
}