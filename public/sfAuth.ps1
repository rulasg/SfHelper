
Set-MyInvokeCommandAlias -Alias sforglistauth -Command "sf org list auth --json"
Set-MyInvokeCommandAlias -Alias sforgloginweb -Command "sf org login web --instance-url {instanceUrl} --json"
Set-MyInvokeCommandAlias -Alias sforglogout -Command "sf org logout --all --no-prompt --json"
Set-MyInvokeCommandAlias -Alias sforgdisplayuser -Command "sf org display --target-org {email} --verbose --json"
Set-MyInvokeCommandAlias -Alias sfLoginWithSFDX -Command " '{sfdxAuthUrl}'| sf org login sfdx-url --sfdx-url-stdin"
Set-MyInvokeCommandAlias -Alias ghSetSecret -Command "gh secret set {secretname} --body '{secretvalue}'"
Set-MyInvokeCommandAlias -Alias ghSetSecretUser -Command "gh secret set {secretname} -u --body '{secretvalue}'"

<#
.SYNOPSIS
Retrieves authorization information about Salesforce orgs.

.DESCRIPTION
This function calls the Salesforce CLI command `sf org list auth` to list authorization information about the orgs you created or logged into.
The command uses local authorization information cached by Salesforce CLI and does not connect to the orgs to verify their status, making it execute quickly.

.EXAMPLE
Get-SfAuthInfoUser

This example retrieves the authorization information for the Salesforce orgs.

.NOTES
If the command fails, an error message "Error in sf org list auth" will be written to the error stream.
#>
function Get-SfAuthList{
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
} Export-ModuleMember -Function Get-SfAuthList

function Test-SfAuthConnected{
    [CmdletBinding()]
    param()

    $result = Get-SfAuthList

    return $null -ne $result

} Export-ModuleMember -Function Test-SfAuthConnected
    

function Get-SfAuthUser{
    [CmdletBinding()]
    param ()

    $result = Get-SfAuthList

    $ret = -not $result ? $null : $result.username

    return $ret

} Export-ModuleMember -Function Get-SfAuthUser

function Get-SfAuthInfoUser {
    [CmdletBinding()]
    param (
        [Parameter()][string]$Email
    )

    $Email = Resolve-Email -Email $Email

    # Check if the email is valid
    if (-not $Email) {
        Write-Error "Invalid email address."
        return
    }

    # Create the authentication file content
    $json = Invoke-MyCommand -Command sforgdisplayuser -Parameter @{ email = $Email} -ErrorAction SilentlyContinue

    $ret = $json | Out-String

    return $ret
} Export-ModuleMember -Function Get-SfAuthInfoUser

function Get-SfAuthInfoBase64{
    [CmdletBinding()]
    param ()

    $text = Get-SfAuthInfoUser

    $base64 = $text | ConvertTo-Base64
    #-ErrorAction SilentlyContinue

    return $base64
} Export-ModuleMember -Function Get-SfAuthInfoBase64

function Save-SfAuthInfoToSecret{
    [CmdletBinding()]
    param(
        # secret name
        [Parameter()][string]$SecretName = "SFDX_AUTH_URL"
    )

    $base64 = Get-SfAuthInfoBase64

    if ($base64){
        $result = Invoke-MyCommand -Command ghSetSecret -Parameter @{ secretname = $SecretName; secretvalue = $base64 }
        return $result
    }

    return $false
} Export-ModuleMember -Function Save-SfAuthInfoToSecret

function Save-SfAuthInfoToUserSecret{
    [CmdletBinding()]
    param(
        # secret name
        [Parameter()][string]$SecretName = "SFDX_AUTH_URL"
    )

    $base64 = Get-SfAuthInfoBase64

    if ($base64){
        $result = Invoke-MyCommand -Command ghSetSecretUser -Parameter @{ secretname = $SecretName; secretvalue = $base64 }
        return $result
    }

    return $false
} Export-ModuleMember -Function Save-SfAuthInfoToUserSecret

function Connect-SfAuthWithAuthBase64 {
    [CmdletBinding()]
    param (
        [Parameter()] [string]$Base64 = $env:SFDX_AUTH_URL
        )
    # sf org login sfdx-url --sfdx-url-file authFile.json

    if([string]::IsNullOrWhiteSpace($Base64)){
        throw "Base64 string is null or empty."
    }

    $sfdxAuthUrl = $Base64 | base64 --decode | ConvertFrom-Json | Select-Object -ExpandProperty result | Select-Object -ExpandProperty sfdxAuthUrl

    
    $result = Invoke-MyCommand -Command sfLoginWithSFDX -Parameter @{sfdxAuthUrl = $sfdxAuthUrl } -ErrorAction SilentlyContinue

    return $result

} Export-ModuleMember -Function Connect-SfAuthWithAuthBase64

function Connect-SfAuthWeb{
    [CmdletBinding()]
    param(
        [Parameter()][string]$InstanceUrl = "https://github.my.salesforce.com"
    )

    $email = Resolve-Email

    $json = Invoke-MyCommand -Command sforgloginweb -Parameters @{ instanceUrl = $InstanceUrl } -ErrorAction SilentlyContinue 

    $json | Write-MyVerbose

    $result = $json | ConvertFrom-Json -Depth 10 -AsHashtable

    if($result.status -ne 0){
        "Login failed. Login invocation result: $json" | Write-MyError
        return $null
    }

    $ret = $result.result

    # TODO: Change Check if the login was successful using email once we know the result when login fails

    $ret.Remove("accessToken")
    $ret.Remove("refreshToken")

    return $ret
} Export-ModuleMember -Function Connect-SfAuthWeb

function Disconnect-SfAuth{
    [CmdletBinding()]
    param()

    $result = Invoke-MyCommand -Command "sforglogout" -ErrorAction SilentlyContinue 

    $result | Write-MyVerbose

    $result = $result | ConvertFrom-Json -Depth 10

    if($result.status -ne 0){
        throw "Status $($result.status)"
    }





} Export-ModuleMember -Function Disconnect-SfAuth

function ConvertTo-Base64 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline, Position=0)][string[]]$Text,
        [Parameter()][switch]$Decode
    )

    process{

        if ($Decode) {
            # Decode the base64 string
            $ret = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Text))
        } else {
            # Encode the string to base64
            $ret = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Text))
        }

        return $ret
    }
}