
Set-InvokeCommandAlias -Alias NewAuthFile -Command "sf org display --target-org {email} --verbose --json"
Set-InvokeCommandAlias -Alias sfLoginWithAuthFile -Command "sf org login sfdx-url --sfdx-url-file {filename}"
Set-InvokeCommandAlias -Alias getBase64 -Command "'{text}' | Invoke-Base64"
Set-InvokeCommandAlias -Alias getBase64-decode -Command "'{text}' | Invoke-Base64 -Decode"

function New-SfAuthFile {
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
    $json = Invoke-MyCommand -Command NewAuthFile -Parameter @{ email = $Email; filename = $FilePath } -ErrorAction SilentlyContinue 

    $ret = $json | Out-String

    return $ret
} Export-ModuleMember -Function New-SfAuthFile

function New-SfAuthBase64{
    [CmdletBinding()]
    param ()

    $text = New-SfAuthFile

    $base64 = Invoke-MyCommand -Command getBase64 -Parameter @{ text = $text }
    #-ErrorAction SilentlyContinue

    return $base64
} Export-ModuleMember -Function New-SfAuthBase64

function New-SfAuthFileFromBase64 {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline,Mandatory = $true)][string]$Base64
    )

    $filename = "authFile.json"

    # Decode the base64 string
    $decodedText = Invoke-Base64 -Text $Base64 -Decode

    # Convert the JSON string to a PowerShell object
    $decodedText | Out-File -Path $filename -Force

    return $filename
} Export-ModuleMember -Function New-SfAuthFileFromBase64

function Invoke-Base64 {
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
} Export-ModuleMember -Function Invoke-Base64


function Invoke-sfLoginWithAuthFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string]$FilePath
        )
    # sf org login sfdx-url --sfdx-url-file authFile.json

    $Email = Resolve-Email -Email $Email

    # Create the authentication file content
    Invoke-MyCommand -Command sfLoginWithAuthFile -Parameter @{filename = $FilePath } -ErrorAction SilentlyContinue


} Export-ModuleMember -Function Invoke-sfLoginWithAuthFile


