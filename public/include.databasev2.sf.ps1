# This file is required for INCLUDE DATABASE V2

$DB_INVOKE_GET_ROOT_PATH_ALIAS = "SfGetDbRootPath"
$DB_INVOKE_GET_ROOT_PATH_CMD = "Invoke-SfGetDbRootPath"

Set-MyInvokeCommandAlias -Alias $DB_INVOKE_GET_ROOT_PATH_ALIAS -Command $DB_INVOKE_GET_ROOT_PATH_CMD

function Invoke-SfGetDbRootPath{
    [CmdletBinding()]
    param()

    $databaseRoot = GetDatabaseRootPath
    return $databaseRoot

} Export-ModuleMember -Function Invoke-SfGetDbRootPath