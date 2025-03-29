function Test_SaveSfAuthInfoToSecret{

    Reset-InvokeCommandMock
    $filename = "sforgdisplayVerbose.json"
    $base64 = Get-MockFileContent -filename $filename | ConvertTo-Base64
    MockCallToString -Command "gh api user --jq '.email'" -OutString "me@contoso.com"
    MockCall -Command "sf org display --target-org me@contoso.com --verbose --json" -filename $filename

    MockCallToNull -Command "gh secret set SFDX_AUTH_URL --body '$base64'"

    $result = Save-SfAuthInfoToSecret

    Assert-IsNull -Object $result

    # TODO: Assert that we are in fact callinggh secret set with the proper parameters

}

function Test_SaveSfAuthInfoToSecret{

    Reset-InvokeCommandMock
    $filename = "sforgdisplayVerbose.json"
    $base64 = Get-MockFileContent -filename $filename | out-string | ConvertTo-Base64
    MockCallToString -Command "gh api user --jq '.email'" -OutString "me@contoso.com"
    MockCall -Command "sf org display --target-org me@contoso.com --verbose --json" -filename $filename
    MockCallToNull -Command "gh secret set SFDX_AUTH_URL --body '$base64' -u -r 'ownername/reponame'"
    MockCallToString -Command "git remote get-url origin" -OutString "https://github.com/ownername/reponame.git"

    $result = Save-SfAuthInfoToSecret -User

    Assert-IsNull -Object $result

    # TODO: Assert that we are in fact callinggh secret set with the proper parameters

}

function Test_ConnectSfAuthWeb{

    Reset-InvokeCommandMock
    MockCallToString -Command "gh api user --jq '.email'" -OutString "me@contoso.com"
    MockCall -Command "sf org login web --instance-url https://contoso.my.salesforce.com --json" -fileName "sforgloginweb.json"

    $result = Connect-SfAuthWeb -InstanceUrl "https://contoso.my.salesforce.com"

    Assert-AreEqual -Presented $result.username -Expected "me@contoso.com"
    Assert-AreEqual -Presented $result.instanceUrl -Expected "https://contoso.my.salesforce.com"

    Assert-IsNull -Object $result.accessToken
    Assert-IsNull -Object $result.refreshToken

}

function Test_ConnectSfAuthBase64{
    Reset-InvokeCommandMock

    $filename = "sforgdisplayVerbose.json"
    $SDX_AUTH_URL = Get-MockFileContent -filename $filename | ConvertTo-Base64 | Out-String

    $command = "'force://PlatformCLI::xxx@contoso.my.salesforce.com'| sf org login sfdx-url --sfdx-url-stdin --json"
    MockCall -Command $command -filename $filename

    $result = Connect-SfAuthBase64 -Base64 $SDX_AUTH_URL

    Assert-AreEqual -Expected "me@contoso.com" -Presented $result
}
function Test_GetRepoName{

    Reset-InvokeCommandMock
    MockCallToString -Command "git remote get-url origin" -OutString "https://github.com/contoso/reponame.git"

    $result = Get-RepoName

    Assert-AreEqual -Expected "contoso/reponame" -Presented $result

}