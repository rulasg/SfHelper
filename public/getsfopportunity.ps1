<#
.SYNOPSIS
Retrieves Salesforce Opportunity data based on the specified Salesforce URL.

.DESCRIPTION
The `Get-SfOpportunity` function extracts the Salesforce Opportunity ID from the provided URL and retrieves the specified attributes for the Opportunity object. It uses the `Get-SfDataQuery` function to perform the query and returns the result as a PowerShell object. The function also performs transformations to clean up certain fields.

.PARAMETER SfUrl
The Salesforce URL of the Opportunity object to query.

.PARAMETER AdditionalAttributes
Additional attributes to retrieve from the Opportunity object. This parameter accepts a comma-separated string of attribute names.

.PARAMETER Force
Forces the function to bypass any caching
when retrieving data. If this switch is set, the function will always query Salesforce for the latest data, regardless of any cached results.

.OUTPUTS
The function returns a PowerShell object representing the queried Salesforce Opportunity data. If the query is unsuccessful or the object is not found, the function returns `$null`.

.EXAMPLE
PS> $sfUrl = "https://example.salesforce.com/0013o00002OHreEAAT"
PS> $result = Get-SfOpportunity -SfUrl $sfUrl
PS> $result

This example retrieves the specified attributes for the Salesforce Opportunity object with the ID extracted from the provided URL.

#>
function Get-SfOpportunity{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$SfUrl,
        [string]$AdditionalAttributes,
        [switch]$Force,
        [Parameter()][string]$Id
    )

    if ([string]::IsNullOrWhiteSpace($Id)){
        # Extract Id from URL
        $Id = Get-SfObjectIdFromUrl -SfUrl $SfUrl
        $type = Get-SfObjectTypeFromUrl -SfUrl $SfUrl
        
        if ($type -ne "Opportunity") {
            throw "Invalid Salesforce Object URL $SfUrl"
        }
    }

    $attributes = @(
        "Id",
        "Name"
        "OwnerId"
        # "Industry",
        # "Account_Owner__c",
        # "Account_Segment__c",
        # "Account_Owner_Role__c",
        # "Account_Tier__c",
        # "Potential_Seats__c",
        # "Country_Name__c",
        # "Current_Seats__c",
        # "Current_ARR_10__c",
        # "Salesforce_Record_URL__c"
    )

    # Add attributes from parameter
    if ($AdditionalAttributes) {
        $additionalAttributesArray = $AdditionalAttributes -split ","
        "adding attributes from additional attributes $additionalAttributesArray" | Write-Verbose
        $attributes += $additionalAttributesArray | Select-Object -Unique
    }

    ## Add attributes from file
    if (Test-Configuration ) {
        $config = Get-Configuration
        $attributesFromConfig = $config.opportunity_attributes
        "adding attributes from config $($attributesFromConfig -join ',' )" | Write-Verbose
        $attributes += $attributesFromConfig | Select-Object -Unique
    }

    # Get object
    $ret = Get-SfDataQuery -Type opportunity -Id $Id -Attributes $attributes -Force:$Force

    # Transformations

    # $ret.PsObject.Properties.Remove("attributes")

    return $ret
} Export-ModuleMember -Function Get-SfOpportunity
