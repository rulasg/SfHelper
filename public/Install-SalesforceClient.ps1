
Set-MyInvokeCommandAlias -Alias GetNpmVersion -Command "npm --version"
Set-MyInvokeCommandAlias -Alias SalesforceCliInstall -Command "npm install @salesforce/cli --global"

function Install-SalesforceClient{
    [CmdletBinding()]
    param()

    # check that npm is install in the system
    $result = Invoke-MyCommand -Command GetNpmVersion
    if($null -eq $result){
        throw "npm not installed. Please install npm to install Sf-Cli through npm."
    }

    "Installing Salesforce CLI using npm..." | Write-MyHost
    $result = Invoke-MyCommand -Command SalesforceCliInstall

    return $result
}