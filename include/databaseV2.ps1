# DATABASE V2
#
# Database driver to store the cache
#
# Include design description
# This is the function ps1. This file is the same for all modules.
# Create a public psq with variables, Set-MyInvokeCommandAlias call and Invoke public function.
# Invoke function will call back `GetDatabaseRootPath` to use production root path
# Mock this Invoke function with Set-MyInvokeCommandAlias to set the Store elsewhere
# This ps1 has function `GetDatabaseFile` that will call `Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_ALIAS`
# to use the store path, mocked or not, to create the final store file name.
# All functions of this ps1 will depend on `GetDatabaseFile` for functionality.
#
# TODO : Create a related public ps1
# 1. define $DB_INVOKE_GET_ROOT_PATH_ALIAS. Make it unique.
# 2. define $DB_INVOKE_GET_ROOT_PATH_CMD. Point to the invoke function that calls GetConfigRootPath to get the store path
#
# Sample code (replace "MyModule" with a unique module prefix):
#   $DB_INVOKE_GET_ROOT_PATH_ALIAS = "SfGetDbRootPath"
#   $DB_INVOKE_GET_ROOT_PATH_CMD = "Invoke-SfGetDbRootPath"
#
#   Set-MyInvokeCommandAlias -Alias $DB_INVOKE_GET_ROOT_PATH_ALIAS -Command $DB_INVOKE_GET_ROOT_PATH_CMD
#  
#   function Invoke-SfGetDbRootPath{
#       [CmdletBinding()]
#       param()
#  
#       $databaseRoot = GetDatabaseRootPath
#       return $databaseRoot
#  
#   } Export-ModuleMember -Function Invoke-SfGetDbRootPath

$moduleRootPath = $PSScriptRoot | Split-Path -Parent
$moduleName = (Get-ChildItem -Path $moduleRootPath -Filter *.psd1 | Select-Object -First 1).BaseName
$DATABASE_ROOT = [System.Environment]::GetFolderPath('UserProfile') | Join-Path -ChildPath ".helpers" -AdditionalChildPath $moduleName, "databaseCache"

# Create the database root if it does not exist
if(-Not (Test-Path $DATABASE_ROOT)){
    New-Item -Path $DATABASE_ROOT -ItemType Directory
}

function GetDatabaseRootPath {
    [CmdletBinding()]
    param()

    $databaseRoot = $DATABASE_ROOT
    return $databaseRoot
}

function GetDatabaseFile{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )

    # throw if DB_INVOKE_GET_ROOT_PATH_ALIAS is not set
    if (-not $DB_INVOKE_GET_ROOT_PATH_ALIAS) {
        throw "DB_INVOKE_GET_ROOT_PATH_ALIAS is not set. Please set it before calling GetDatabaseFile."
    }

    $databaseRoot = Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_ALIAS

    $path = $databaseRoot | Join-Path -ChildPath "$Key.json"

    return $path
}

function Get-Database{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )

    if(-Not (Test-Database $Key)){
        return $null
    }

    $path =  GetDatabaseFile $Key

    $ret = Get-Content $path | ConvertFrom-Json -Depth 10 -AsHashtable

    return $ret
}

function Reset-Database{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )
    $path =  GetDatabaseFile -Key $Key
    Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
    return
}

function Save-Database{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key,
        [Parameter(Position = 2)][Object]$Database
    )

    $path = GetDatabaseFile -Key $Key

    $Database | ConvertTo-Json -Depth 10 | Set-Content $path
}

function Test-Database{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )

    $path = GetDatabaseFile -Key $Key

    # Key file not exists
    if(-Not (Test-Path $path)){
        return $false
    }

    # TODO: Return $false if cache has expired

    return $true
}

