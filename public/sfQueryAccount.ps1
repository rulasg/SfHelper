
Set-MyInvokeCommandAlias -Alias "sfaccountget" -Command  'sf data query --query "SELECT {attributes} FROM Account WHERE Id=''{id}''" -r=json'

function Get-SfAccount{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    $params = @{
        id = $Id
        attributes = "OwnerId,Name,Id,Account_Owner__c,Account_Segment__c,Account_Tier__c,Potential_Seats__c"
    }

    $result = Invoke-MyCommand -Command "sfaccountget" -Param $params

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