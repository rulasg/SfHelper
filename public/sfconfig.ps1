# Required by INCLUDE CONFIG

$CONFIG_INVOKE_GET_ROOT_PATH_ALIAS = "SfGetConfigRootPath"
$CONFIG_INVOKE_GET_ROOT_PATH_CMD = "Invoke-SfGetConfigRootPath"

Set-MyInvokeCommandAlias -Alias $CONFIG_INVOKE_GET_ROOT_PATH_ALIAS -Command $CONFIG_INVOKE_GET_ROOT_PATH_CMD

function Invoke-SfGetConfigRootPath{
    $configRoot = GetConfigRootPath
    return $configRoot
} Export-ModuleMember -Function Invoke-SfGetConfigRootPath


# Extra functions not needed by INCLUDE CONFIG

function Get-SfConfig{
    [CmdletBinding()]
    param()

    $config = Get-Configuration

    return $config
} Export-ModuleMember -Function Get-SfConfig

function Save-SfConfig{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][Object]$Config
    )

    return Save-Configuration -Config $Config
} Export-ModuleMember -Function Save-SfConfig

function Open-SfConfig{
    [CmdletBinding()]
    param()

    $path = GetConfigFile -Key "config"

    code $path

} Export-ModuleMember -Function Open-SfConfig

function Add-SfConfigAttribute{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$Attribute
    )

    begin{
        $config = Get-Configuration

        if(-Not $config){
            $config = @{}
        }
    
        if(-Not $config.account_attributes){
            $config.account_attributes = @()
        }
    }

    process{
        $config.account_attributes += $Attribute
    }
    
    End{
        $ret = Save-Configuration -Config $config
        if(-Not $ret){
            throw "Error saving configuration"
        }

        $config = Get-SfConfig
        Write-Output $config.account_attributes
        
    }

} Export-ModuleMember -Function Add-SfConfigAttribute
