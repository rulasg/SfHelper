
$DB_INVOKE_GET_ROOT_PATH_CMD = "Invoke-SfGetDbRootPath"

function Mock_Database([switch]$ResetDatabase){

    MockCallToString $DB_INVOKE_GET_ROOT_PATH_CMD -OutString "test_database_path"

    if($ResetDatabase){
        Reset-DatabaseStore
    }

}