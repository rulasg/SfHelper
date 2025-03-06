
$PROFILE_ATTRIBUTES_FILE_PATH = "~/.helpers/sfhelper/sfattributes.txt"


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
        [string]$AdditionalAttributes
    )

    # Extract Id from URL
    $Id = Get-SfObjectIdFromUrl -SfUrl $SfUrl

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

    if ($AdditionalAttributes) {
        $additionalAttributesArray = $AdditionalAttributes -split ","
        "adding attributes from additional attributes $additionalAttributesArray" | Write-Verbose
        $attributes += $additionalAttributesArray | Select-Object -Unique
    }

    ## Add attributes from file
    if (Test-Configuration ) {
        $config = Get-Configuration
        $attributesFromConfig = $config.attributes
        "adding attributes from config $($attributesFromConfig -join ',' )" | Write-Verbose
        $attributes += $attributesFromConfig | Select-Object -Unique
    }

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

<# 
.SYNOPSIS
Edit profile attributes file
#>
function Edit-SfProfileAttributesFile {
    param (
        [string]$FilePath = $PROFILE_ATTRIBUTES_FILE_PATH
    )

    if (-not (Test-Path $FilePath)) {
        $null = New-Item -Path $FilePath -ItemType File -Force
    }

    Write-Host $FilePath

    code $FilePath
} Export-ModuleMember -Function Edit-SfProfileAttributesFile
