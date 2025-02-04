
Set-MyInvokeCommandAlias -Alias "sfDataQuery" -Command  'sf data query --query "SELECT {attributes} FROM {type} WHERE Id=''{id}''" -r=json'

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
        [Parameter(Mandatory,Position=0)][string]$Id
    )

    $attributes =@(
        "Id",
        "Name",
        "OwnerId",
        "Industry",
        "Account_Owner__c",
        "Account_Segment__c",
        "Account_Owner_Role__c"
        "Account_Tier__c",
        "Potential_Seats__c",
        "Country_Name__c",
        "Current_Seats__c",
        "Current_ARR_10__c"
    )

    # Get object
    $ret = Get-SfDataQuery -Type Account -Id $Id -Attributes $attributes

    # Transformations
    $ownerHtml = $ret.Account_Owner__c
    $ownerName = [string]::IsNullOrEmpty($ownerHtml) ? "" : $(Get-OwnerNameFromHtml -html $ownerHtml)
    Add-Member -InputObject $ret -MemberType NoteProperty -Name "OwnerName" -Value $ownerName

    $ret.PSObject.Properties.Remove("Account_Owner__c")
    $ret.PsObject.Properties.Remove("attributes")

    return $ret
} Export-ModuleMember -Function Get-SfAccount

# Function to extract Owner Name from HTML
function Get-OwnerNameFromHtml {
    param (
        [string]$html
    )
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
    $ret.PsObject.Properties.Remove("attributes")

    return $ret

} Export-ModuleMember -Function Get-SfUser