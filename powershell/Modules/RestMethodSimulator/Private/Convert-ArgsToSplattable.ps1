function Convert-ArgsToSplattable {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [object[]]$Arguments
    )

    $paramHash = @{}
    for ($i = 0; $i -lt $Arguments.Count; $i++) {
        $arg = $Arguments[$i]
        if ($arg -match '^[-/]') {
            $paramName = $arg -replace '^[-/]+|:$', ''
            if ($i -lt $Arguments.Count - 1 -and $Arguments[$i+1] -notmatch '^[-/]') {
                $paramHash[$paramName] = $Arguments[$i+1]
                $i++ # Skip the next item as we've already processed it
            }
            else {
                # It's a switch parameter
                $paramHash[$paramName] = $true
            }
        }
        elseif ($i -eq 0) {
            # First position parameter is typically Uri
            $paramHash["Uri"] = $arg
        } else {
            throw "RequestMocker needs named parameters to function properly"
        }
    }
    
    return $paramHash
}