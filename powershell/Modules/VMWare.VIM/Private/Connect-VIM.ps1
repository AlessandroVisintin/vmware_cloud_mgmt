function Connect-VIM {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Server,
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )
    $version = Get-VIMVersion -Address $Server
    switch -Wildcard ($version) {
        "8*" { return [VIMv8]::new($Server, $Credential) }
        default { throw "Unsupported VIM version" }
    }

}