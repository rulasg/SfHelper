
<#
.SYNOPSIS
Retrieves Salesforce Account data based on the specified Salesforce URL.

.DESCRIPTION
The `Get-SfAccount` function extracts the Salesforce Account ID from the provided URL and retrieves the specified attributes for the Account object. It uses the `Get-SfDataQuery` function to perform the query and returns the result as a PowerShell object. The function also performs transformations to clean up certain fields.

.PARAMETER SfUrl
The Salesforce URL of the Account object to query.

.OUTPUTS
The function returns a PowerShell object representing the queried Salesforce Account data. If the query is unsuccessful or the object is not found, the function returns `$null`.

.EXAMPLE
PS> $sfUrl = "https://example.salesforce.com/0013o00002OHreEAAT"
PS> $result = Get-SfAccount -SfUrl $sfUrl
PS> $result

This example retrieves the specified attributes for the Salesforce Account object with the ID extracted from the provided URL.

.NOTES
The function uses the `Get-SfDataQuery` function to perform the query and the `Get-OwnerNameFromHtml` function to clean up the `Account_Owner__c` field.

#>
function Get-SfAccount{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$SfUrl,
        [string]$AdditionalAttributes,
        [switch]$Force
    )

    # Extract Id from URL
    $Id = Get-SfObjectIdFromUrl -SfUrl $SfUrl
    $type = Get-SfObjectTypeFromUrl -SfUrl $SfUrl

    if ($type -ne "Account") {
        throw "Invalid Salesforce Object URL $SfUrl"
    }

    $attributes = @(
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

    # Add attributes from parameter
    if ($AdditionalAttributes) {
        $additionalAttributesArray = $AdditionalAttributes -split ","
        "adding attributes from additional attributes $additionalAttributesArray" | Write-Verbose
        $attributes += $additionalAttributesArray | Select-Object -Unique
    }

    ## Add attributes from config
    if (Test-Configuration ) {
        $config = Get-Configuration
        $attributesFromConfig = $config.account_attributes
        "adding attributes from config $($attributesFromConfig -join ',' )" | Write-Verbose
        $attributes += $attributesFromConfig | Select-Object -Unique
    }

    # Get object
    $ret = Get-SfDataQuery -Type Account -Id $Id -Attributes $attributes -Force:$Force

    # Transformations
    $ret = $ret | Edit-AttributeValueFromHTML `
        -AttributeName "Account_Owner__c" `
        -NewAttributeName "OwnerName" `
        -RemoveOriginalAttribute

    return $ret
} Export-ModuleMember -Function Get-SfAccount


