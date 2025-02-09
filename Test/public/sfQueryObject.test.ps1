function Test_GetSfApiRequest{

    Assert-SkipTest "Avoid calling Salesforce API in tests"

    $result = Get-SfApiRequest -objectType "Account" -Id "0015c000028FY0pAAG"

    Assert-AreEqual -Expected "0015c000028FY0pAAG" -Presented $result.Id
}