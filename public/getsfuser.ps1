<#
.SYNOPSIS
Retrieves user information from Salesforce.

.DESCRIPTION
This function retrieves user information using the `sf data query` command.

.PARAMETER Id
The Salesforce user ID.

.PARAMETER AdditionalAttributes
Additional attributes to retrieve from the User object. This parameter accepts a comma-separated string of attribute names.

.PARAMETER Force
Forces the function to bypass any caching
when retrieving data. If this switch is set, the function will always query Salesforce for the latest data, regardless of any cached results.

.OUTPUTS
The function returns a PowerShell object representing the queried Salesforce User data. If the query is unsuccessful or the object is not found, the function returns `$null`.

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
        [string]$Id,
        [string]$AdditionalAttributes,
        [switch]$Force
    )

    $attributes = @(
        "Id",
        "Name",
        "GitHub_Username__c",
        "Email",
        "Department",
        "ManagerId",
        "Username",
        "Title"
    )

    if ($AdditionalAttributes) {
        $additionalAttributesArray = $AdditionalAttributes -split ","
        $attributes += $additionalAttributesArray | Select-Object -Unique
    }

    # Get object
    $ret = Get-SfDataQuery -Type User -Id $Id -Attributes $attributes -Force:$Force

    # remove attributes
    # $ret.PsObject.Properties.Remove("attributes")

    return $ret
} Export-ModuleMember -Function Get-SfUser