function Test_sfAuth_InvokeBase64{

    # Assert-SkipTest

    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule

    $text = New-SfAuthFile
    $os = $text | base64
    $invoke = $text | Invoke-Base64
    $myCommand= Invoke-MyCommand -Command getBase64 -Parameter @{ text = $text }

    $os_de = $os | base64 --decode | Out-String
    $invoke_de = $invoke | Invoke-Base64 -Decode
    $myCommand_de = Invoke-MyCommand -Command getBase64-decode -Parameter @{ text = $myCommand }

    $original = $text | ConvertFrom-Json -Depth 10
    $os_obj = $os_de | ConvertFrom-Json -Depth 10
    $invoke_obj = $invoke_de | ConvertFrom-Json -Depth 10
    $myCommand_obj = $myCommand_de | ConvertFrom-Json -Depth 10

    Assert-AreEqual -Expected $original.result.accesstoken -Presented $os_obj.result.accesstoken
    Assert-AreEqual -Expected $original.result.accesstoken -Presented $invoke_obj.result.accesstoken
    Assert-AreEqual -Expected $original.result.accesstoken -Presented $myCommand_obj.result.accesstoken
}

function Test_sfAuth_New_SfAuthFile{

    # Assert-SkipTest
    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule

    $obj = New-SfAuthFile | ConvertFrom-Json -Depth 10
    
    $result = New-SfAuthBase64

    $result_de = $result | base64 --decode | Out-String | ConvertFrom-Json -Depth 10

    Assert-AreEqual -Expected $obj.result.accesstoken -Presented $result_de.result.accesstoken
}

function Test_NewSfAuthFileFromBase64{
    # Assert-SkipTest
    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule

    $result = New-SfAuthBase64

    $filename = New-SfAuthFileFromBase64 -Base64 $result
    $obj = Get-Content -Path $filename -Raw | ConvertFrom-Json -Depth 10

    Assert-IsNotNull -Object $obj.result.accesstoken

}