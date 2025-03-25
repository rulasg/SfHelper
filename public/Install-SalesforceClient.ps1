
Set-MyInvokeCommandAlias -Alias GetNpmVersion -Command "npm --version"
Set-MyInvokeCommandAlias -Alias SalesforceCliInstall -Command "npm install @salesforce/cli --global"
Set-MyInvokeCommandAlias -Alias GetSalesforceCliVersion -Command "sf --version"
Set-MyInvokeCommandAlias -Alias SalesforceCliSetConfig -Command "sf config set --global target-org {email} --json"
Set-MyInvokeCommandAlias -Alias GetUserEmail -Command '$env:GITHUB_USER ? "$($env:GITHUB_USER)@github.com" : $null'

# Set-MyInvokeCommandAlias -Alias SalesforceCliLogin -Command "sf org login device"
Set-MyInvokeCommandAlias -Alias SalesforceCliDisplay -COmmand "sf org display --json"
Set-MyInvokeCommandAlias -Alias SalesforceCliGetConfig -Command "sf config get target-org --json"

function Install-SalesforceClient{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    # check that npm is install in the system
    $result = Invoke-MyCommand -Command GetNpmVersion
    if($null -eq $result){
        throw "0. npm not installed. Please install npm to allow the installation of Salesforce Cli through npm."
    } else {
        "0. npm installed. version: $result" | Write-ToConsole -Color "Green"
    }

    # Check for Salesforce CLI installed and install if not
    $sfversion = Invoke-MyCommand -Command GetSalesforceCliVersion -ErrorAction SilentlyContinue
    if($null -eq $sfversion){
        if ($PSCmdlet.ShouldProcess("Target", "Operation")) {
            "Installing Salesforce CLI using npm..." | Write-MyHost
            Invoke-MyCommand -Command SalesforceCliInstall
        }
    }

    # Sf installation check
    $sfversion = Invoke-MyCommand -Command GetSalesforceCliVersion -ErrorAction SilentlyContinue
    if($null -eq $sfversion){
        "1. Salesforce Cli installation failed. Run ""npm install @salesforce/cli --global"" to install manually!!!" | Write-MyError
        return
    } else{
        "1. Salesforce CLI installed. Version: $sfversion} " | Write-ToConsole -Color "Green"
    }

    # Sf logging
    $result = Invoke-MyCommand -Command SalesforceCliDisplay -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
    $result | Write-MyVerbose
    $user = $result.result
    if($user.connectedStatus -eq "Connected"){
        "2. Salesforce CLI already connected with user $($user.username)" | Write-ToConsole -Color "Green"
    } else {
       "2. Run the following command to loging to Salesforce CLI: ""sf org login device""" | Write-ToConsole -Color "Magenta"
       return
    }

    # # Logging in to Salesforce CLI
    # "Loging in to Salesforce CLI..." | Write-MyHost
    # if ($PSCmdlet.ShouldProcess("Target", "Operation")) {
        #     Invoke-MyCommand -Command SalesforceCliLogin
        # }

    $result = Invoke-MyCommand -Command SalesforceCliGetConfig -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
    $result | Write-MyVerbose
    $config = $result.result
    if($config.success){
        "3. Salesforce CLI configured with user $($config.value)" | Write-ToConsole -Color "Green"
    } else {
        "3. Salesforce CLI not configured. Run the following command to configure Salesforce CLI: ""sf config set --global target-org {email}""" | Write-ToConsole -Color "Magenta"
        return
    }

    # # Configure Salesforce CLI
    # $email = Invoke-MyCommand -Command GetUserEmail
    # "Configuring Salesforce CLI ..." | Write-MyHost
    # if($email){
    #     $json = Invoke-MyCommand -Command SalesforceCliSetConfig -Parameters @{ email = $email }
    #     $result = $json | ConvertFrom-Json -ErrorAction SilentlyContinue
    #     if($user.result.successes.success){
    #         "Configured Salesforce CLI with user $($user.result.successes.value) " | Write-MyHost
    #     } else {
    #         "Salesforce CLI configuration failed with email $email" | Write-MyError
    #         return
    #     }
    # } else {
    #     "Can not find your github user. Run the following command to configure your Salesforce CLI: sf config set --global target-org {email}" | Write-MyHost
    #     "Salesforce CLI installed but pending to be configured." | Write-MyWarning
    #     return
    # }

} Export-ModuleMember -Function Install-SalesforceClient