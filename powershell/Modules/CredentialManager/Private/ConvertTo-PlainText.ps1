function ConvertTo-PlainText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [System.Security.SecureString]$SecureString
    )
    
    try {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        $plainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        return $plainText
    }
    catch {
        Write-Error "Failed to convert secure string to plain text: $_"
        return $null
    }
    finally {
        ## IMPORTANT: clean up potential plain text password
        if ($BSTR -ne [IntPtr]::Zero) {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        }
    }
}