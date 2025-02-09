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

    $ret | Add-Member -MemberType NoteProperty -Name "QueryDate" -Value (Get-Date)

    return $ret
}



