function Get-SfObjectIdFromUrl {
    param (
        [string]$SfUrl
    )

    $uri = [System.Uri]::new($SfUrl)
    $segments = $uri.Segments

    # "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB/view"
    # "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB/"
    # "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB"
    if ($segments.Length -ge 4 -and $segments[1] -eq "lightning/" -and $segments[2] -eq "r/") {
        return $segments[4].TrimEnd('/')

    #"https://github.my.salesforce.com/0010V00002Q8r78QAB"
    } elseif ($segments.Length -eq 2) {
        return $segments[-1].TrimEnd('/')

    } else {
        throw "Invalid Salesforce Object URL $SfUrl"
    }
}

function Get-SfObjectTypeFromUrl {
    param (
        [string]$SfUrl
    )

    $uri = [System.Uri]::new($SfUrl)
    $segments = $uri.Segments

    # "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB/view"
    # "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB/"
    # "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB"
    if ($segments.Length -ge 3 -and $segments[1] -eq "lightning/" -and $segments[2] -eq "r/") {
        return $segments[3].TrimEnd('/')

    #"https://github.my.salesforce.com/0010V00002Q8r78QAB"
    } elseif ($segments.Length -eq 2) {
        return $null

    } else {
        throw "Invalid Salesforce Object URL $SfUrl"
    }
}

