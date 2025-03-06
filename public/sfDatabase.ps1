

$DB_INVOKE_GET_ROOT_PATH_ALIAS = "SfGetDbRootPath"
$DB_INVOKE_GET_ROOT_PATH_CMD = "Invoke-SfGetDbRootPath"

Set-MyInvokeCommandAlias -Alias $DB_INVOKE_GET_ROOT_PATH_ALIAS -Command $DB_INVOKE_GET_ROOT_PATH_CMD

function Invoke-SfGetDbRootPath{
    [CmdletBinding()]
    param()

    $databaseRoot = GetDatabaseRootPath
    return $databaseRoot

} Export-ModuleMember -Function Invoke-SfGetDbRootPath


function Reset-DatabaseStore{
    [CmdletBinding()]
    param()

        $databaseRoot = Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_ALIAS
    
        Remove-Item -Path $databaseRoot -Recurse -Force -ErrorAction SilentlyContinue

        New-Item -Path $databaseRoot -ItemType Directory

} Export-ModuleMember -Function Reset-DatabaseStore