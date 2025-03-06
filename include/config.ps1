# Configuration management module

# Create a related public ps1 and define $CONFIG_INVOKE_ALIAS. Make it unique.

$moduleName = Get-ModuleName
$CONFIG_ROOT = [System.Environment]::GetFolderPath('UserProfile') | Join-Path -ChildPath ".helpers" -AdditionalChildPath $moduleName, "config"

# Create the config root if it does not exist
if(-Not (Test-Path $CONFIG_ROOT)){
    New-Item -Path $CONFIG_ROOT -ItemType Directory
}

function GetConfigRootPath {
    [CmdletBinding()]
    param()

    $configRoot = $CONFIG_ROOT
    return $configRoot
}

function GetConfigFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Key
    )

    $configRoot = Invoke-MyCommand -Command $CONFIG_INVOKE_ALIAS
    $path = Join-Path -Path $configRoot -ChildPath "$Key.json"
    return $path
}

function Test-Configuration {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key = "config"
    )

    $path = GetConfigFile -Key $Key

    return Test-Path $path
}

function Get-Configuration {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key = "config"
    )

    $path = GetConfigFile -Key $Key

    if(-Not (Test-Configuration -Key $Key)){
        return $null
    }

    try{
        $ret = Get-Content $path | ConvertFrom-Json -ErrorAction Stop
        return $ret
    }
    catch{
        Write-Warning "Error reading configuration ($Key) file: $($path). $($_.Exception.Message)"
        return $null
    }
}

function Save-Configuration {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key = "config",
        [Parameter(Mandatory = $true, Position = 1)][Object]$Config
    )

    $path = GetConfigFile -Key $Key

    try {
        $Config | ConvertTo-Json -Depth 10 | Set-Content $path -ErrorAction Stop
    }
    catch {
        Write-Warning "Error saving configuration ($Key) to file: $($path). $($_.Exception.Message)"
        return $false
    }

    return $true
}










