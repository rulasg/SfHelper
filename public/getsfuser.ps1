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