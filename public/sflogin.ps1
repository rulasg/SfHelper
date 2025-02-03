Set-MyInvokeCommandAlias -Alias "sforglistauth" -Command "sf org list auth --json"
Set-MyInvokeCommandAlias -Alias "sforglogin" -Command "sf org login device"

function Get-SfOrgListAuth{
    [CmdletBinding()]
    param()

    try {
        $result = Invoke-MyCommand -Command "sforglistauth" 
        
        $obj = $result | ConvertFrom-Json -Depth 10

        if($obj.status -ne 0){
            throw "Status $($obj.status)"
        }
        
        return $obj.result
    }
    catch {
        "Error in sf org list auth " | Write-Error
    }
} Export-ModuleMember -Function Get-SfOrgListAuth

function New-SfOrgLogin{
    [CmdletBinding()]
    param()

    'Run "sf org login device" too login to Salesforce' | Write-Host

} Export-ModuleMember -Function New-SfOrgLogin