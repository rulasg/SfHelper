
$DB_INVOKE_GET_ROOT_PATH_CMD = "Invoke-SfGetDbRootPath"

function Mock_Database([switch]$ResetDatabase){

    MockCallToString $DB_INVOKE_GET_ROOT_PATH_CMD -OutString "test_database_path"

    $dbstore = Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_CMD
    Assert-AreEqual -Expected "test_database_path" -Presented $dbstore

    if($ResetDatabase){
        Reset-DatabaseStore
    }

}

function Get-Mock_DatabaseStore{
    $dbstore = Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_CMD
    return $dbstore
}