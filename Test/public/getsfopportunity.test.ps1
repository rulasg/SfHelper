function Test_GetSfOpportunity{

    Reset-InvokeCommandMock
    Mock_Database -ResetDatabase
    Mock_Config

    # Mock Sf call
    $id = "0065c00001SFRbYAAX"
    $cacheFileName = "sfDataQuery-opportunity-$id-5106802FEB193611777BC7DA26122EF5.json"
    $url = "https://github.lightning.force.com/lightning/r/Opportunity/$id/view"
    Mock_SfDataQuery_Opportunity_0065c00001SFRbYAAX

    # Act with out cache
    $result = Get-SfOpportunity -SfUrl $url

    # Assert
    Assert-AreEqual -Expected $id -Presented $result.Id
    $path = Get-Mock_DatabaseStore | Join-Path -ChildPath $cacheFileName
    Assert-ItemExist -Path $path

    # Remove sf data
    Reset-InvokeCommandMock
    Mock_Database
    Mock_Config

    # Act with cache
    $result = Get-SfOpportunity -SfUrl $url

    # Assert
    Assert-AreEqual -Expected $id -Presented $result.Id

}

function  Test_GetSfOpportunity_Live{
    Assert-SkipTest "Test live connection to Salesforce"

    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule

    $result = Get-SfOpportunity https://github.lightning.force.com/lightning/r/Opportunity/0065c00001SFRbYAAX/view
    Assert-notnull -Object $result

    Assert-NotImplemented
}

function Test_GetSfOpportunity_Id{
    Reset-InvokeCommandMock

    # Mocks
    Mock_Database -ResetDatabase
    Mock_Config
    Mock_SfDataQuery_Opportunity_0065c00001SFRbYAAX

    # Act with out cache
    $result = Get-SfOpportunity -Id 0065c00001SFRbYAAX

    # Assert
    Assert-AreEqual -Expected "0065c00001SFRbYAAX" -Presented $result.Id
}

function Mock_SfDataQuery_Opportunity_0065c00001SFRbYAAX{
    [CmdletBinding()]
    param()

    $attrib = "Id,Name,OwnerId"
    $type = "Opportunity"
    $id = "0065c00001SFRbYAAX"
    $filename = "sf-data-query-opportunity_0065c00001SFRbYAAX.json"

    Mock_SfDataQuery -attrib $attrib -type $type -id $id -filename $filename
}