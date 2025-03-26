Set-MyInvokeCommandAlias -Alias GetUserEmail -Command "gh api user --jq '.email'"
Set-MyInvokeCommandAlias -Alias GetNpmVersion -Command "npm --version"
Set-MyInvokeCommandAlias -Alias SfCliInstall -Command "npm install @salesforce/cli --global"
Set-MyInvokeCommandAlias -Alias SfCliVersion -Command "sf --version"
Set-MyInvokeCommandAlias -Alias SfCliDisplay -COmmand "sf org display --target-org={email} --json"
Set-MyInvokeCommandAlias -Alias SfCliGetConfig -Command "sf config get target-org --json"
Set-MyInvokeCommandAlias -Alias SfCliSetConfig -Command "sf config set --global target-org {email} --json"


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
    [CmdletBinding(SupportsShouldProcess)]
    param()

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
} Export-ModuleMember -Function Invoke-SfInstall

function Test-SfLogin{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()][string]$Email
    )

    $email = Resolve-Email -Email $Email

    # Sf logging
    $result = Invoke-MyCommand -Command SfCliDisplay -Parameters @{ email = $email } -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
    $result | Write-MyVerbose
    $user = $result.result
    if($user.connectedStatus -eq "Connected"){
        "2. Salesforce CLI already connected with user $($user.username)" | Write-ToConsole -Color "Green"
        return $user.username
    } else {
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
        "3. Salesforce CLI configured with user $($Email) " | Write-MyHost
        return $Email
    } else {
        "3. Salesforce CLI configuration failed with email $Email. Logging to Salesforce Cli and try again. " | Write-MyError
        $result | ConvertTo-Json -Depth 10 | Write-MyVerbose
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