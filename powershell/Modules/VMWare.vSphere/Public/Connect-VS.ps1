function Connect-VS {
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

    $version = Get-VSVersion -Address $Server
    switch -Wildcard ($version) {
        "8*" { return [VSv8]::new($Server, $Credential) }
        default { throw "Unsupported VIM version" }
    }
}
