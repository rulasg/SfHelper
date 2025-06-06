Set-MyInvokeCommandAlias -Alias GetNpmVersion -Command "npm --version"
Set-MyInvokeCommandAlias -Alias SfCliInstall -Command "npm install @salesforce/cli --global"
Set-MyInvokeCommandAlias -Alias SfCliVersion -Command "sf --version"
Set-MyInvokeCommandAlias -Alias SfCliGetConfig -Command "sf config get target-org --json"
Set-MyInvokeCommandAlias -Alias SfCliSetConfig -Command "sf config set --global target-org {email} --json"


function Initialize-SfEnvironment{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    # 0. NPM setup check
    if(-not (Test-NpmSetup)){return}

    # 1. Sf Install
    if(-not (Install-SfClient)){return}

    # 2. Test Sf Login
    $email = Initialize-SfConnection
    if(-not $email){return}

    # 3. Sf Config
    if(-not(Set-SfConfig -Email:$email)){return}

    return $email

} Export-ModuleMember -Function Initialize-SfEnvironment

function Test-NpmSetup{
    [CmdletBinding()]

    $result = Invoke-MyCommand -Command GetNpmVersion -ErrorAction SilentlyContinue

    if($result){
        "0. npm installed. version: $result" | Write-ToConsole -Color "Green"
        return $true
    } else {
        throw "0. npm not installed. Please install npm to allow the installation of Salesforce Cli through npm."
        return $false
    }
} Export-ModuleMember -Function Test-NpmSetup

function Install-SfClient{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()][switch]$Force
    )

    # Run installaltion if Force is set
    # This command allows to update the Salesforce CLI if already installed
    if($Force){
        "Installing Salesforce CLI using npm..." | Write-MyHost
        Invoke-MyCommand -Command SfCliInstall
    }

    # Check if npm is installed

    # Check and Install for Salesforce CLI installed and install if not
    $sfversion = Invoke-MyCommand -Command SfCliVersion -ErrorAction SilentlyContinue
    if($null -eq $sfversion){
        if ($PSCmdlet.ShouldProcess("Target", "Operation")) {
            "Installing Salesforce CLI using npm..." | Write-MyHost
            Invoke-MyCommand -Command SfCliInstall
        }
    }
    $sfversion = Invoke-MyCommand -Command SfCliVersion -ErrorAction SilentlyContinue
    if($null -eq $sfversion){
        "1. Salesforce Cli installation failed. Run ""npm install @salesforce/cli --global"" to install manually!!!" | Write-MyError
        return $false
    } else{
        "1. Salesforce CLI installed. Version: $sfversion} " | Write-ToConsole -Color "Green"
        return $true
    }
} Export-ModuleMember -Function Install-SfClient

function Initialize-SfConnection{
    [CmdletBinding()]
    param()

    # Check already connected
    $userName = Get-SfAuthUser
    if($userName){
        "2. Salesforce CLI already connected with user $($userName)" | Write-ToConsole -Color "Green"
        return $userName
    }

    # Connect using base64
    $userName = Connect-SfAuthBase64 -ErrorAction SilentlyContinue
    if($userName){
        "2. Salesforce Cli connected usin base64 with user $($userName)" | Write-ToConsole -Color "Green"
        return $userName
    }
    # Connect using web
    $userName = Connect-SfAuthWeb -ErrorAction SilentlyContinue
    if($userName){
        "2. Salesforce CLI connected using web with user $($userName)" | Write-ToConsole -Color "Green"
        return $userName
    }

    # Not Connected
    $message = @"
2. Salesforce CLI not connected. Please connect or set environment to allow connection.
    1. Set environment variable SFDX_AUTH_URL. Use Get-SfAuthInfoBase64 on an already Sf connected environment to get the value.
    2. Login manually through the web. Use Connect-SfAuthWeb or Sf command 'sf org login web'
    3. Login manually through the device. Use Sf command 'sf org login device'
"@

    $message | Write-ToConsole -Color "Magenta"

} Export-ModuleMember -Function Initialize-SfConnection

function Test-SfConnect{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Email
    )

    $userName = Get-SfAuthUser
    
    if(-not $userName){
        Connect-SfAuthWeb
    }

    $userName = Get-SfAuthUser

    if(-not $userName){
        "2. Salesforce CLI not connected. Set environment variable SFDX_AUTH_URL. Use Get-SfAuthInfoBase64 on an Sf connected environment to get the value. Use ""sf org login device"" to connect to Sf." | Write-ToConsole -Color "Magenta"
        return $null
     } else {
        "2. Salesforce CLI connected with user $userName." | Write-ToConsole -Color "Green"
     }

} Export-ModuleMember -Function Test-SfConnect

function Set-SfConfig{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()][string]$Email
    )

    $Email = Resolve-Email -Email $Email

    "Using email $Email to configure Salesforce CLI" | Write-MyVerbose

    $result = Invoke-MyCommand -Command SfCliGetConfig -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
    $result | Write-MyVerbose
    $config = $result.result
    if($result.result.value -eq $Email){
        "3. Salesforce CLI already configured with user $($config.value)" | Write-ToConsole -Color "Green"
        return $true
    }

    # Configure Salesforce CLI
    "Configuring Salesforce CLI ..." | Write-MyVerbose

    $result = Invoke-MyCommand -Command SfCliSetConfig -Parameters @{ email = $Email } | ConvertFrom-Json -Depth 10 -ErrorAction SilentlyContinue
    if($result.result.successes.value -eq $Email){
        "3. Salesforce CLI configured with user $($Email) " | Write-ToConsole -Color "Green"
        return $Email
    } else {
        "3. Salesforce CLI configuration failed with email $Email. Logging to Salesforce Cli and try again. " | Write-MyError
        $result | ConvertTo-Json -Depth 10 | Write-MyVerbose
        return
    }

} Export-ModuleMember -Function Set-SfConfig