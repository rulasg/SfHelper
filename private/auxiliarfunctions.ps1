function Get-SfObjectIdFromUrl {
    param (
        [string]$SfUrl
    )

    $id,$type = Get-SfObjectInfoFromUrl -SfUrl $SfUrl

    return $id
}

function Get-SfObjectTypeFromUrl {
    param (
        [string]$SfUrl
    )

    $id,$type = Get-SfObjectInfoFromUrl -SfUrl $SfUrl

    return $type
}

function Get-SfObjectInfoFromUrl {
    [CmdletBinding()]
    param (
        [string]$SfUrl
    )

    $uri = [System.Uri]::new($SfUrl)
    $segments = $uri.Segments

    # Salesforce ID pattern: 15 or 18 alphanumeric characters
    $sfIdPattern = '^[a-zA-Z0-9]{15}([a-zA-Z0-9]{3})?$'

    # /lightning/r/ paths
    if ($segments.Length -ge 4 -and $segments[1] -eq "lightning/" -and $segments[2] -eq "r/") {

        $candidate = $segments[3].TrimEnd('/')

        if ($candidate -match $sfIdPattern) {
            # "https://github.lightning.force.com/lightning/r/0010V00002Q8r78QAB/view"
            return $candidate, $null
        } elseif ($segments.Length -ge 5) {
            # "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB/view"
            # "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB"
            $type = $candidate
            $id = $segments[4].TrimEnd('/')
            return $id, $type
        } else {
            throw "Invalid Salesforce Object URL $SfUrl"
        }

    # "https://github.my.salesforce.com/0010V00002Q8r78QAB"
    } elseif ($segments.Length -eq 2) {
        $id = $segments[-1].TrimEnd('/')
        return $id, $null

    } else {
        throw "Invalid Salesforce Object URL $SfUrl"
    }
}

