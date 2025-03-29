function Test_InitializeSfEnvironment{

    Assert-SkipTest

    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule

    $email = Resolve-Email

    $result = Initialize-SfEnvironment

    Assert-IsNotNull -Object $result

    Assert-AreEqual -Presented $result -Expected $email
}