function Test_GetSfUserByHandle{

    Reset-InvokeCommandMock

    # Mocks
    Mock_Database -ResetDatabase
    Mock_Config

    # Mock Sf call
    $handle = "rulasg"
    Mock_SfDataQueryWithWhere_User_rulasg

    # Act
    $result = Get-SfUserByHandle -Handle $handle

    # Assert
    Assert-AreEqual -Expected "Hashtable" -Presented $result.GetType().BaseType.Name
    Assert-AreEqual -Expected "0055c000009T2o8AAC" -Presented $result.Id
    Assert-AreEqual -Expected "Rulas Ghost" -Presented $result.Name
    Assert-AreEqual -Expected "rulasg" -Presented $result.GitHub_Username__c
    Assert-AreEqual -Expected "rulasg@github.com" -Presented $result.Email
}

function Test_GetSfUserByHandle_Cache{

    Reset-InvokeCommandMock

    # Mocks
    Mock_Database -ResetDatabase
    Mock_Config

    # Mock Sf call
    $handle = "rulasg"
    Mock_SfDataQueryWithWhere_User_rulasg

    # Act with out cache
    $result = Get-SfUserByHandle -Handle $handle

    # Assert
    Assert-AreEqual -Expected "0055c000009T2o8AAC" -Presented $result.Id

    # Reset Mock and skip Mock_SfDataQueryWithWhere_User_rulasg
    Reset-InvokeCommandMock
    Mock_Database
    Mock_Config

    # Act with cache
    $result = Get-SfUserByHandle -Handle $handle

    # Assert
    Assert-AreEqual -Expected "Hashtable" -Presented $result.GetType().BaseType.Name
    Assert-AreEqual -Expected "0055c000009T2o8AAC" -Presented $result.Id
    Assert-AreEqual -Expected "rulasg" -Presented $result.GitHub_Username__c
}
