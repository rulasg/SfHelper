Set-MyInvokeCommandAlias -Alias "sfDataQuery" -Command  'sf data query --query "SELECT {attributes} FROM {type} WHERE Id=''{id}''" -r=json'
Set-MyInvokeCommandAlias -Alias "sfApiRequest" -Command 'sf api request --url "/services/data/v62.0/sobjects/{objectType}/{id}"'

function Get-SfDataQuery{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet("Account", "User")][string]$Type,
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string[]]$Attributes
    )

    $params = @{
        id = $Id
        type = $Type
        attributes = $attributes -join ","
    }

    $result = Invoke-MyCommand -Command "sfDataQuery" -Param $params

    $obj = $result | ConvertFrom-Json -Depth 10

    if($obj.status -ne 0){
        throw "Status $($obj.status)"
    }

    if($obj.result.done -ne $true){
        throw "Done is not true. Something went wrong."
    }

    if($obj.result.TotalSize -eq 0){
        "Account not found" | Write-Host
        return $null
    }

    $ret = $obj.result.records

    return $ret
} Export-ModuleMember -Function Get-SfAccount

function Get-SfAccount{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$SfUrl
    )

    # Extract Id from URL
    $Id = Get-SfObjectIdFromUrl -SfUrl $SfUrl

    $attributes =@(
        "Id",
        "Name",
        "OwnerId",
        "Industry",
        "Account_Owner__c",
        "Account_Segment__c",
        "Account_Owner_Role__c",
        "Account_Tier__c",
        "Potential_Seats__c",
        "Country_Name__c",
        "Current_Seats__c",
        "Current_ARR_10__c",
        "Salesforce_Record_URL__c"
    )

    # Get object
    $ret = Get-SfDataQuery -Type Account -Id $Id -Attributes $attributes

    # Transformations

    ## Clean up the Account_Owner__c field to show the name of the owner
    Add-Member -InputObject $ret -MemberType NoteProperty -Name "OwnerName" -Value $(Get-OwnerNameFromHtml -html $($ret.Account_Owner__c))
    $ret.PSObject.Properties.Remove("Account_Owner__c")

    # $ret.PsObject.Properties.Remove("attributes")

    return $ret
} Export-ModuleMember -Function Get-SfAccount

# Function to extract Owner Name from HTML
function Get-OwnerNameFromHtml {
    param (
        [string]$html
    )

    if ([string]::IsNullOrEmpty($html)) {
        return ""
    }

    if ($html -match '<a[^>]*>([^<]+)</a>') {
        return $matches[1]
    }
    return $null
}

function Get-SfUser{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)]
        [string]$Id
    )

    $attributes =@(
        "Id",
        "Name"
        "GitHub_Username__c",
        "Email",
        "Department",
        "ManagerId",
        "Username",
        "Title"
    )

    # Get object
    $ret = Get-SfDataQuery -Type User -Id $Id -Attributes $attributes

    # remove attributes
    # $ret.PsObject.Properties.Remove("attributes")

    return $ret

} Export-ModuleMember -Function Get-SfUser

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
} Export-ModuleMember -Function Get-SfObjectIdFromUrl

function Get-SfApiRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$SfUrl
    )

    # Extract Id from URL
    $Id = Get-SfObjectIdFromUrl -SfUrl $SfUrl

    # Call the sfApiRequest alias
    $params = @{
        objectType = "Account"  # Assuming the object type is Account
        id = $Id
    }
    $result = Invoke-MyCommand -Command "sfApiRequest" -Param $params

    # Parse the output as JSON
    $obj = $result | ConvertFrom-Json -Depth 10

    if ($obj.status -ne 0) {
        throw "Status $($obj.status)"
    }

    return $obj
} Export-ModuleMember -Function Get-SfApiRequest

