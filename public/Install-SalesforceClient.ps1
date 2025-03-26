Set-MyInvokeCommandAlias -Alias GetUserEmail -Command "gh api user --jq '.email'"
Set-MyInvokeCommandAlias -Alias GetNpmVersion -Command "npm --version"
Set-MyInvokeCommandAlias -Alias SalesforceCliInstall -Command "npm install @salesforce/cli --global"
Set-MyInvokeCommandAlias -Alias GetSalesforceCliVersion -Command "sf --version"
Set-MyInvokeCommandAlias -Alias SalesforceCliSetConfig -Command "sf config set --global target-org {email} --json"

# Set-MyInvokeCommandAlias -Alias SalesforceCliLogin -Command "sf org login device"
Set-MyInvokeCommandAlias -Alias SalesforceCliDisplay -COmmand "sf org display --json"
Set-MyInvokeCommandAlias -Alias SalesforceCliGetConfig -Command "sf config get target-org --json"

function Install-SalesforceClient{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()][string]$Email
    )

    # 0. NPM setup check
    if(-not (Test-NpmSetup)){return}

    # 1. Sf Install
    if(-not (Invoke-SfInstall)){return}

    # 2. Test Sf Login
    if(-not (Test-SfLogin)){return}

    # 3. Sf Config
    if(-not(Invoke-SfConfig -Email:$Email)){return}

} Export-ModuleMember -Function Install-SalesforceClient

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

function Invoke-SfInstall{
    [CmdletBinding()]
    param()

    # Check and Install for Salesforce CLI installed and install if not
    $sfversion = Invoke-MyCommand -Command GetSalesforceCliVersion -ErrorAction SilentlyContinue
    if($null -eq $sfversion){
        if ($PSCmdlet.ShouldProcess("Target", "Operation")) {
            "Installing Salesforce CLI using npm..." | Write-MyHost
            Invoke-MyCommand -Command SalesforceCliInstall
        }
    }
    $sfversion = Invoke-MyCommand -Command GetSalesforceCliVersion -ErrorAction SilentlyContinue
    if($null -eq $sfversion){
        "1. Salesforce Cli installation failed. Run ""npm install @salesforce/cli --global"" to install manually!!!" | Write-MyError
        return $false
    } else{
        "1. Salesforce CLI installed. Version: $sfversion} " | Write-ToConsole -Color "Green"
        return $true
    }
} Export-ModuleMember -Function Invoke-SfInstall

function Test-SfLogin{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    # Sf logging
    $result = Invoke-MyCommand -Command SalesforceCliDisplay -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
    $result | Write-MyVerbose
    $user = $result.result
    if($user.connectedStatus -eq "Connected"){
        "2. Salesforce CLI already connected with user $($user.username)" | Write-ToConsole -Color "Green"
        return $user.username
       "2. Run the following command to loging to Salesforce CLI: ""sf org login device""" | Write-ToConsole -Color "Magenta"
       return $null
    }

    # # Logging in to Salesforce CLI
    # "Loging in to Salesforce CLI..." | Write-MyHost
    # if ($PSCmdlet.ShouldProcess("Target", "Operation")) {
    #     Invoke-MyCommand -Command SalesforceCliLogin
    # }
} Export-ModuleMember -Function Test-SfLogin

function Invoke-SfConfig{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()][string]$Email
    )

    $Email = Resolve-Email -Email $Email

    "Using email $Email to configure Salesforce CLI" | Write-MyVerbose

    # $result = Invoke-MyCommand -Command SalesforceCliGetConfig -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
    # $result | Write-MyVerbose
    # $config = $result.result
    # if($config.success){
    #     "3. Salesforce CLI already configured with user $($config.value)" | Write-ToConsole -Color "Green"
    #     return
    # }

    # Configure Salesforce CLI
    "Configuring Salesforce CLI ..." | Write-MyVerbose

    $result = Invoke-MyCommand -Command SalesforceCliSetConfig -Parameters @{ email = $Email } | ConvertFrom-Json -ErrorAction SilentlyContinue
    if($result.result.successes.value -eq $Email){
        "3. Salesforce CLI configured with user $($Email) " | Write-ToConsole -Color "Green"
        return $Email
    } else {
        "3. Salesforce CLI configuration failed with email $Email. " | Write-MyError
        $result | ConvertTo-Json |  Write-MyVerbose
        return
    }

} Export-ModuleMember -Function Invoke-SfConfig

function Resolve-Email{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()][string]$Email
    )

    if(-not [string]::IsNullOrEmpty($Email)){
        "Resolving email [$Email] from parameter" | Write-MyVerbose
        return $Email
    }

    $Email = Invoke-MyCommand -Command GetUserEmail -ErrorAction SilentlyContinue
    "Resolved email [$Email] from github" | Write-MyVerbose

    if ($null -eq $Email){
        throw "Unable to resolve user email. Please provide email as parameter or set proper gh cli credentials and user github profile email." | Write-MyError
    }

    return $Email

} Export-ModuleMember -Function Resolve-Email