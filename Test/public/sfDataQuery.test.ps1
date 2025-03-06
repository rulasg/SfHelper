function Test_GetSfAccount{

    Reset-InvokeCommandMock
    Mock_Database -ResetDatabase
    $mockAttrib = @{attributes = @("Potential_Seats_Manual__c","Website","PhotoUrl")}
    Mock_Config -Config $mockAttrib

    $dbstore = Invoke-MyCommand -Command GetDatabaseStorePath
    Assert-AreEqual -Expected "test_database_path" -Presented $dbstore

    $attrib = "Id,Name,OwnerId,Industry,Account_Owner__c,Account_Segment__c,Account_Owner_Role__c,Account_Tier__c,Potential_Seats__c,Country_Name__c,Current_Seats__c,Current_ARR_10__c,Salesforce_Record_URL__c,Potential_Seats_Manual__c,Website,PhotoUrl"
    $type = "Account"
    $id = "0010V00002KIWkaQAH"

    $command = 'sf data query --query "SELECT {attributes} FROM {type} WHERE Id=''{id}''" -r=json'
    $command = $command -replace "{attributes}", $attrib
    $command = $command -replace "{type}", $type
    $command = $command -replace "{id}", $id
    MockCall -Command $command -filename "sf-data-query-account.json"

    # Act with out cache
    $result = get-sfAccount https://github.lightning.force.com/lightning/r/Account/0010V00002KIWkaQAH/view
    Assert-AreEqual -Expected $Id -Presented $result.Id
    $dbfiles = Get-ChildItem $dbstore
    Assert-Count -Expected 1 -Presented $dbfiles
    Assert-IsTrue -Condition ($dbfiles[0].Name -like "sfDataQuery*-$type-$id-*.json")

    # Remove sf data 
    Reset-InvokeCommandMock
    Mock_Database
    Mock_Config -Config $mockAttrib

    # Act with cache
    $result = Get-SfAccount https://github.lightning.force.com/lightning/r/Account/0010V00002KIWkaQAH/view
    Assert-AreEqual -Expected $Id -Presented $result.Id

}