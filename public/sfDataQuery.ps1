Set-MyInvokeCommandAlias -Alias "sfDataQuery" -Command  'Invoke-SfDataQuery -Type {type} -Id {id} -Attributes "{attributes}"'
Set-MyInvokeCommandAlias -Alias "sfDataQueryWithWhere" -Command  'Invoke-SfDataQueryWithWhere -From {from} -Where "{where}" -Attributes "{attributes}"'

$script:dbCache = @{}

function Get-SfDataQuery{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet("Account", "User", "Opportunity","AccountTeamMember","GitHub_Account_Teams__c")][string]$Type,
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string[]]$Attributes,
        [switch]$Force
    )
    
    # Get Cache Key to read or write the output
    $cacheKey = getcacheKey -Type $Type -Id $Id -Attributes $Attributes

    "[Get-SfDataQuery] $cacheKey" | Write-MyDebug -section "SfDataQuery"

    # avoid cache if Force is set
    if(-Not $Force){

        # Memory
        if($script:dbCache.ContainsKey($cacheKey)){
            "[Get-SfDataQuery] 🟩 Memory Cache hit for key $cacheKey" | Write-MyDebug -section "SfDataQuery"
            return $script:dbCache[$cacheKey]
        }

        # Testcache first
        if(Test-Database -Key $cacheKey){

            "[Get-SfDataQuery] 🟧 Cache hit for key $cacheKey" | Write-MyDebug -section "SfDataQuery"
            $ret = Get-Database -Key $cacheKey
            $script:dbCache[$cacheKey] = $ret
            return $ret

        } else{
            "[Get-SfDataQuery] 🟥 Cache miss for key $cacheKey" | Write-MyDebug -section "SfDataQuery"
        }
    } else {
        "[Get-SfDataQuery] 🚫 Force is set. Ignoring cache for key $cacheKey" | Write-MyDebug -section "SfDataQuery"
    }

    $params = @{
        id = $Id
        type = $Type
        attributes = $attributes -join ","
    }

    $result = Invoke-MyCommand -Command "sfDataQuery" -Parameters $params

    "[Get-SfDataQuery] Result for Id $Id and Type $Type" | Write-MyDebug -section "SfDataQuery" -Object $result

    $obj = $result | ConvertFrom-Json -Depth 10 -asHashtable

    if($obj.status -ne 0){
        throw "Status $($obj.status) . Enable debug logging to see more details."
    }

    if($obj.result.done -ne $true){
        throw "Done is not true. Something went wrong."
    }

    if($obj.result.TotalSize -eq 0){
        "$Type not found" | Write-Host
        return $null
    }

    $ret = $obj.result.records

    $ret | Add-Member -MemberType NoteProperty -Name "QueryDate" -Value (Get-Date)

    "[Get-SfDataQuery] ⭕️ Saving to $cacheKey" | Write-MyDebug -section "SfDataQuery"
    $script:dbCache[$cacheKey] = $ret
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
    $attributesHash = $attribString | Get-HashCode
    "AttributesHash : $attributesHash" | Write-Verbose

    $cacheKey = "sfDataQuery-$Type-$Id-$attributesHash"

    "CacheKey : $cacheKey" | Write-Verbose

    return $cacheKey
}

function getcacheKey2{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$From,
        [Parameter(Mandatory)][string]$Where,
        [Parameter(Mandatory)][string[]]$Attributes,
        [Parameter(Mandatory)][string]$Name
    )

    # Add hash of attributes to key
    $attribString = $Attributes -join ","
    $attributesHash = $attribString | Get-HashCode
    Write-MyDebug "HASH $attributesHash from string $attribString" -section "sfDataQuery"

    $wherehash = $Where | Get-HashCode
    Write-MyDebug "HASH $wherehash from string $Where" -section "sfDataQuery"

    $cacheKey = "sfDataQuery-$From-$wherehash-$attributesHash"
    $cacheKey =[string]::isNullOrWhiteSpace($Name) ? $cacheKey : "$Name-$cacheKey"

    Write-MyDebug "CacheKey : $cacheKey" -section "sfDataQuery"

    return $cacheKey
}

function Invoke-SfDataQuery{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet("Account", "User", "Opportunity","AccountTeamMember","GitHub_Account_Teams__c")][string]$Type,
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Attributes

    )

    switch ($Type) {
        "Account" { $idName = "Id" }
        "User" { $idName = "Id" }
        "Opportunity" { $idName = "Id" }
        "AccountTeamMember" { $idName = "AccountId" }
        "GitHub_Account_Teams__c" { $idName = "Account__c" }
        default { throw "Invalid type $Type" }
    }

    $command = 'sf data query --query "SELECT {attributes} FROM {type} WHERE {idName}=''{id}''" -r=json'
    $command = $command -replace "{attributes}", $Attributes
    $command = $command -replace "{type}", $Type
    $command = $command -replace "{idName}", $idName
    $command = $command -replace "{id}", $Id

    Write-MyDebug " >> $command" -section "SfDataQuery"
    
    $response = Invoke-Expression $command
    
    Write-MyDebug " << $command" -section "SfDataQuery"

    Write-MyDebug "Response" -section "SfDataQuery" -Object $response

    return $response

} Export-ModuleMember -Function Invoke-SfDataQuery

function Get-SfDataQueryWithWhere{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$From,
        [Parameter(Mandatory)][string]$Where,
        [Parameter(Mandatory)][string[]]$Attributes,
        [Parameter(Mandatory)][string]$Name,
        [switch]$Force
    )
    
    # Get Cache Key to read or write the output
    $cacheKey = getcacheKey2 -From $From -Where $Where -Attributes $Attributes -Name $Name

    "[Get-SfDataQueryWithWhere] CacheKey : $cacheKey" | Write-MyDebug -section "SfDataQuery"

    # avoid cache if Force is set
    if(-Not $Force){

        # Memory
        if($script:dbCache.ContainsKey($cacheKey)){
            "[Get-SfDataQueryWithWhere] 🟩 Memory Cache hit for key $cacheKey" | Write-MyDebug -section "SfDataQuery"
            return $script:dbCache[$cacheKey]
        }

        # Testcache first
        if(Test-Database -Key $cacheKey){
            "[Get-SfDataQueryWithWhere] 🟧 Cache hit for key $cacheKey" | Write-MyDebug -section "SfDataQuery"
            $ret = Get-Database -Key $cacheKey
            $script:dbCache[$cacheKey] = $ret
            return $ret
        } else{
            "[Get-SfDataQueryWithWhere] 🟥 Cache miss for key $cacheKey" | Write-MyDebug -section "SfDataQuery"
        }
    } else {
        "[Get-SfDataQuery] 🚫 Force is set. Ignoring cache for key $cacheKey" | Write-MyDebug -section "SfDataQuery"
    }

    $params = @{
        where = $Where
        from = $From
        attributes = $attributes -join ","
    }

    $result = Invoke-MyCommand -Command "sfDataQueryWithWhere" -Parameters $params

    "[sfDataQueryWithWhere] Result From $From and Where $Where" | Write-MyDebug -section "SfDataQuery" -Object $result

    $obj = $result | ConvertFrom-Json -Depth 10 -asHashtable

    if($obj.status -ne 0){
        throw "Status $($obj.status)"
    }

    if($obj.result.done -ne $true){
        throw "Done is not true. Something went wrong."
    }

    if($obj.result.TotalSize -eq 0){
        "$From not found" | Write-Host
        return $null
    }

    $ret = $obj.result.records

    $ret | Add-Member -MemberType NoteProperty -Name "QueryDate" -Value (Get-Date)

    "[sfDataQueryWithWhere] ⭕️ Saving to $cacheKey" | Write-MyDebug -section "SfDataQuery"
    $script:dbCache[$cacheKey] = $ret
    Save-Database -Key $cacheKey -Database $ret

    return $ret
} Export-ModuleMember -Function Get-SfDataQueryWithWhere

# Sample : Invoke-SfDataQueryWithWhere -From GitHub_Account_Teams__c -Where 'Account__c=''0013o00002S5hK9AAJ''' -Attributes id
function Invoke-SfDataQueryWithWhere{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$From,
        [Parameter(Mandatory)][string]$Where,
        [Parameter(Mandatory)][string]$Attributes

    )

    $command = 'sf data query --query "SELECT {attributes} FROM {from} WHERE {where}" -r=json'
    $command = $command -replace "{attributes}", $Attributes
    $command = $command -replace "{from}", $From
    $command = $command -replace "{where}", $Where

    Write-MyDebug " >> $command" -section "SfDataQuery"
    
    $response = Invoke-Expression $command
    
    Write-MyDebug " << $command" -section "SfDataQuery"

    Write-MyDebug "Response" -section "SfDataQuery" -Object $response

    return $response

} Export-ModuleMember -Function Invoke-SfDataQueryWithWhere


