Set-MyInvokeCommandAlias -Alias "sforglistauth" -Command "sf org list auth --json"
Set-MyInvokeCommandAlias -Alias "sforglogin" -Command "sf org login device"

<#
.SYNOPSIS
Retrieves authorization information about Salesforce orgs.

.DESCRIPTION
This function calls the Salesforce CLI command `sf org list auth` to list authorization information about the orgs you created or logged into. 
The command uses local authorization information cached by Salesforce CLI and does not connect to the orgs to verify their status, making it execute quickly.

.EXAMPLE
Get-SfAuthInfo

This example retrieves the authorization information for the Salesforce orgs.

.NOTES
If the command fails, an error message "Error in sf org list auth" will be written to the error stream.
#>
function Get-SfAuthInfo{
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
} Export-ModuleMember -Function Get-SfAuthInfo

<#
.SYNOPSIS
Logs into a Salesforce org.

.DESCRIPTION
This function calls the Salesforce CLI command `sf org login device` to log into a Salesforce org using device login.

.EXAMPLE
New-SfOrgLogin

This example logs into a Salesforce org using device login.

.NOTES
This function writes a message to the host indicating that the login command should be run.
#>
function New-SfOrgLogin{
    [CmdletBinding()]
    param()

    'Run "sf org login device" too login to Salesforce' | Write-Host

} Export-ModuleMember -Function New-SfOrgLogin