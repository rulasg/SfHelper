function Mock_Database([switch]$ResetDatabase){

    MockCallToString "Invoke-GetDatabaseStorePath" -OutString "test_database_path"

    if($ResetDatabase){
        Reset-DatabaseStore
    }

}