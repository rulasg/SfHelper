Set-MyInvokeCommandAlias -Alias "sfDataQuery" -Command  'sf data query --query "SELECT {attributes} FROM {type} WHERE Id=''{id}''" -r=json'
Set-MyInvokeCommandAlias -Alias "sfApiRequest" -Command 'sf api request --url "/services/data/v62.0/sobjects/{objectType}/{id}"'

# ...existing code...

<#
.SYNOPSIS
Retrieves account information from Salesforce.

.DESCRIPTION
This function extracts the account ID from a Salesforce URL and retrieves account information using the `sf data query` command.

.PARAMETER SfUrl
The Salesforce URL containing the account ID.

.EXAMPLE
Get-SfAccount -SfUrl "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB/view"

This example retrieves the account information for the specified Salesforce URL.

.NOTES
If the account is not found, an error message "Account not found" will be written to the host.
#>
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

<#
.SYNOPSIS
Makes an API request to Salesforce.

.DESCRIPTION
This function extracts the object ID from a Salesforce URL and makes an API request using the `sf api request` command.

.PARAMETER SfUrl
The Salesforce URL containing the object ID.

.EXAMPLE
Get-SfApiRequest -SfUrl "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB/view"

This example makes an API request for the specified Salesforce URL.

.NOTES
If the API request fails, an error message will be thrown.
#>
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

<#
.SYNOPSIS
Retrieves user information from Salesforce.

.DESCRIPTION
This function retrieves user information using the `sf data query` command.

.PARAMETER Id
The Salesforce user ID.

.EXAMPLE
Get-SfUser -Id "0050V000001Sv7XQAS"

This example retrieves the user information for the specified Salesforce user ID.

.NOTES
If the user is not found, an error message will be thrown.
#>
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

# ...existing code...
