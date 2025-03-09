Set-MyInvokeCommandAlias -Alias "sfApiRequest" -Command 'sf api request rest /services/data/v62.0/sobjects/{objectType}/{id}'

function Get-SfApiRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet("Account", "User", "Opportunity")][string]$objectType,
        [Parameter(Mandatory,Position=1)][string]$Id
    )

    # sf api request rest /services/data/v62.0/sobjects/Account/0013o00002OHreEAAT

    # Call the sfApiRequest alias
    $params = @{
        objectType = $objectType
        id = $Id
    }
    $result = Invoke-MyCommand -Command "sfApiRequest" -Param $params

    # Parse the output as JSON
    $obj = $result | ConvertFrom-Json -Depth 10

    if ($obj.Id -ne $Id) {
        throw "Somwthing went wrong. Result : $obj"
    }

    return $obj
} Export-ModuleMember -Function Get-SfApiRequest


