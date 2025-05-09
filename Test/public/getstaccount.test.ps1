function Test_GetSfAccount{

    Reset-InvokeCommandMock

    $mockAttrib = @{account_attributes = @("Potential_Seats_Manual__c","Website","PhotoUrl")}

    # Mocks
    Mock_Database -ResetDatabase
    Mock_Config -Config $mockAttrib

    # Mock Sf call
    $id = "0010V00002KIWkaQAH"
    $url = "https://github.lightning.force.com/lightning/r/Account/$id/view"
    $filename = "sfDataQuery-Account-$id-01F5F2DFDE481D1146E8D504BB935E4D.json"
    Mock_SfDataQuery_Account_0010V00002KIWkaQAH -AdditionalAttributes $mockAttrib.account_attributes

    # Act with out cache
    $result = Get-SfAccount -SfUrl $url

    # Assert with cache
    Assert-AreEqual -Expected "Hashtable" -Presented $result.GetType().BaseType.Name
    Assert-AreEqual -Expected $id -Presented $result.Id
    $path = Get-Mock_DatabaseStore | Join-Path -ChildPath $filename
    Assert-ItemExist -Path $path

    # Reset Mock and skip Mock_SfDataQuery_Account_0010V00002KIWkaQAH
    Reset-InvokeCommandMock
    Mock_Database
    Mock_Config -Config $mockAttrib

    # Act with cache
    $result = Get-SfAccount -SfUrl $url

    # Assert
    Assert-AreEqual -Expected "Hashtable" -Presented $result.GetType().BaseType.Name
    Assert-AreEqual -Expected "0010V00002KIWkaQAH" -Presented $result.Id
}

function Test_GetSfAccount_cache{

    Reset-InvokeCommandMock

    $mockAttrib = @{account_attributes = @("Potential_Seats_Manual__c","Website","PhotoUrl")}

    # Mocks
    Mock_Database -ResetDatabase
    Mock_Config -Config $mockAttrib

    # Mock Sf call
    $id = "0010V00002KIWkaQAH"
    $url = "https://github.lightning.force.com/lightning/r/Account/$id/view"
    $filename = "sfDataQuery-Account-$id-01F5F2DFDE481D1146E8D504BB935E4D.json"
    Mock_SfDataQuery_Account_0010V00002KIWkaQAH -AdditionalAttributes $mockAttrib.account_attributes

    # Arrange cache with different data
    $result = Get-SfAccount -SfUrl $url
    Assert-AreEqual -Expected "Spain" -Presented $result.Country_Name__c

    # Arrange update cache with different data
    $path = Get-Mock_DatabaseStore | Join-Path -ChildPath $filename
    $mockdata = Get-Content -Path $path -Raw | ConvertFrom-Json -Depth 10 -asHashtable
    $mockdata.Country_Name__c = "kkContry"
    $mockdata | ConvertTo-Json -Depth 10 | Set-Content -Path $path

    # Act with cache
    $result = Get-SfAccount -SfUrl $url
    Assert-AreEqual -Expected "kkContry" -Presented $result.Country_Name__c
    
    # Froce integration to update the cache
    $result = Get-SfAccount -SfUrl $url -Force
    Assert-AreEqual -Expected "Spain" -Presented $result.Country_Name__c

    # Act with cache to get proper name again
    $result = Get-SfAccount -SfUrl $url
    Assert-AreEqual -Expected "Spain" -Presented $result.Country_Name__c
}

function Test_GetSfAccount_Id{
    Reset-InvokeCommandMock

    # Mocks
    Mock_Database -ResetDatabase
    Mock_Config
    Mock_SfDataQuery_Account_0010V00002KIWkaQAH

    # Act with out cache
    $result = Get-SfAccount -Id 0010V00002KIWkaQAH

    # Assert
    Assert-AreEqual -Expected "Hashtable" -Presented $result.GetType().BaseType.Name
    Assert-AreEqual -Expected "0010V00002KIWkaQAH" -Presented $result.Id

}

function Test_GetSfAccount_Transformations{
    Reset-InvokeCommandMock

    # Mocks
    Mock_Database -ResetDatabase
    Mock_Config
    Mock_SfDataQuery_Account_0010V00002KIWkaQAH

    # Act with out cache
    $result = Get-SfAccount https://github.lightning.force.com/lightning/r/Account/0010V00002KIWkaQAH/view

    # Transformation Account_Owner__c -> OwnerName
    Assert-AreEqual -Expected "Oana Dinca" -Presented $result.OwnerName
    Assert-IsNull -Object $result.Account_Owner__c

}

function Mock_SfDataQuery_Account_0010V00002KIWkaQAH{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string[]]$AdditionalAttributes
    )

    $attrib = "Id,Name,OwnerId,Industry,Account_Owner__c,Account_Segment__c,Account_Owner_Role__c,Account_Tier__c,Potential_Seats__c,Country_Name__c,Current_Seats__c,Current_ARR_10__c,Salesforce_Record_URL__c"
    $type = "Account"
    $id = "0010V00002KIWkaQAH"
    $filename = "sf-data-query-account_0010V00002KIWkaQAH.json"

    if ($AdditionalAttributes) {
        $attrib += "," + ($AdditionalAttributes -join ",")
    }

    Mock_SfDataQuery -attrib $attrib -type $type -id $id -filename $filename
}
