Set-MyInvokeCommandAlias -Alias "sfDataQuery" -Command  'sf data query --query "SELECT {attributes} FROM {type} WHERE Id=''{id}''" -r=json'

function Get-SfDataQuery{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet("Account", "User")][string]$Type,
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string[]]$Attributes
    )

    # Testcache first
    $cacheKey = getcacheKey -Type $Type -Id $Id -Attributes $Attributes
    if(Test-Database -Key $cacheKey){
        return Get-Database -Key $cacheKey
    }

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

    $ret | Add-Member -MemberType NoteProperty -Name "QueryDate" -Value (Get-Date)

    Save-Database -Key $cacheKey -Database $ret

    return $ret
}

function getcacheKey{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Type,
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string[]]$Attributes
    )

    # Add hash of attributes to key
    $attribString = $Attributes -join ","
    "Attributes : $attribString" | Write-Verbose
    $attributesHash = $attribString.GetHashCode()
    "AttributesHash : $attributesHash" | Write-Verbose

    $cacheKey = "sfDataQuery-$Type-$Id-$attributesHash"

    "CacheKey : $cacheKey" | Write-Verbose

    return $cacheKey
}



