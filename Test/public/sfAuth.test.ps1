function Test_SaveSfAuthInfoToSecret{

    Reset-InvokeCommandMock
    MockCallToString -Command "gh api user --jq '.email'" -OutString "me@contoso.com"
    MockCall -Command "sf org display --target-org me@contoso.com --verbose --json" -filename "sforgdisplayVerbose.json"

    MockCallToNull -Command "gh secret set SFDX_AUTH_URL --body 'ewogICJzdGF0dXMiOiAwLAogICJyZXN1bHQiOiB7CiAgICAiaWQiOiAiMDBEZDAwMDAwMDBoSEUwRUFNIiwKICAgICJhcGlWZXJzaW9uIjogIjYzLjAiLAogICAgImFjY2Vzc1Rva2VuIjogIioqKiIsCiAgICAiaW5zdGFuY2VVcmwiOiAiaHR0cHM6Ly9jb250b3NvLm15LnNhbGVzZm9yY2UuY29tIiwKICAgICJ1c2VybmFtZSI6ICJtZUBjb250b3NvLmNvbSIsCiAgICAiY2xpZW50SWQiOiAiUGxhdGZvcm1DTEkiLAogICAgImNvbm5lY3RlZFN0YXR1cyI6ICJDb25uZWN0ZWQiLAogICAgInNmZHhBdXRoVXJsIjogImZvcmNlOi8vUGxhdGZvcm1DTEk6Onh4eEBjb250b3NvLm15LnNhbGVzZm9yY2UuY29tIgogIH0sCiAgIndhcm5pbmdzIjogWwogICAgIlRoaXMgY29tbWFuZCB3aWxsIGV4cG9zZSBzZW5zaXRpdmUgaW5mb3JtYXRpb24gdGhhdCBhbGxvd3MgZm9yIHN1YnNlcXVlbnQgYWN0aXZpdHkgdXNpbmcgeW91ciBjdXJyZW50IGF1dGhlbnRpY2F0ZWQgc2Vzc2lvbi5cblNoYXJpbmcgdGhpcyBpbmZvcm1hdGlvbiBpcyBlcXVpdmFsZW50IHRvIGxvZ2dpbmcgc29tZW9uZSBpbiB1bmRlciB0aGUgY3VycmVudCBjcmVkZW50aWFsLCByZXN1bHRpbmcgaW4gdW5pbnRlbmRlZCBhY2Nlc3MgYW5kIGVzY2FsYXRpb24gb2YgcHJpdmlsZWdlLlxuRm9yIGFkZGl0aW9uYWwgaW5mb3JtYXRpb24sIHBsZWFzZSByZXZpZXcgdGhlIGF1dGhvcml6YXRpb24gc2VjdGlvbiBvZiB0aGUgaHR0cHM6Ly9kZXZlbG9wZXIuc2FsZXNmb3JjZS5jb20vZG9jcy9hdGxhcy5lbi11cy5zZmR4X2Rldi5tZXRhL3NmZHhfZGV2L3NmZHhfZGV2X2F1dGhfd2ViX2Zsb3cuaHRtLiIKICBdCn0KCg=='"

    $result = Save-SfAuthInfoToSecret

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
    $SDX_AUTH_URL = Get-MockFileContent -filename $filename | base64

    $command = "'force://PlatformCLI::xxx@contoso.my.salesforce.com'| sf org login sfdx-url --sfdx-url-stdin --json"
    MockCall -Command $command -filename $filename


    # $result = Connect-SfAuthBase64 -Base64 'ewogICJzdGF0dXMiOiAwLAogICJyZXN1bHQiOiB7CiAgICAiaWQiOiAiMDBEZDAwMDAwMDBoSEUwRUFNIiwKICAgICJhcGlWZXJzaW9uIjogIjYzLjAiLAogICAgImFjY2Vzc1Rva2VuIjogIioqKiIsCiAgICAiaW5zdGFuY2VVcmwiOiAiaHR0cHM6Ly9jb250b3NvLm15LnNhbGVzZm9yY2UuY29tIiwKICAgICJ1c2VybmFtZSI6ICJtZUBjb250b3NvLmNvbSIsCiAgICAiY2xpZW50SWQiOiAiUGxhdGZvcm1DTEkiLAogICAgImNvbm5lY3RlZFN0YXR1cyI6ICJDb25uZWN0ZWQiLAogICAgInNmZHhBdXRoVXJsIjogImZvcmNlOi8vUGxhdGZvcm1DTEk6Onh4eEBjb250b3NvLm15LnNhbGVzZm9yY2UuY29tIgogIH0sCiAgIndhcm5pbmdzIjogWwogICAgIlRoaXMgY29tbWFuZCB3aWxsIGV4cG9zZSBzZW5zaXRpdmUgaW5mb3JtYXRpb24gdGhhdCBhbGxvd3MgZm9yIHN1YnNlcXVlbnQgYWN0aXZpdHkgdXNpbmcgeW91ciBjdXJyZW50IGF1dGhlbnRpY2F0ZWQgc2Vzc2lvbi5cblNoYXJpbmcgdGhpcyBpbmZvcm1hdGlvbiBpcyBlcXVpdmFsZW50IHRvIGxvZ2dpbmcgc29tZW9uZSBpbiB1bmRlciB0aGUgY3VycmVudCBjcmVkZW50aWFsLCByZXN1bHRpbmcgaW4gdW5pbnRlbmRlZCBhY2Nlc3MgYW5kIGVzY2FsYXRpb24gb2YgcHJpdmlsZWdlLlxuRm9yIGFkZGl0aW9uYWwgaW5mb3JtYXRpb24sIHBsZWFzZSByZXZpZXcgdGhlIGF1dGhvcml6YXRpb24gc2VjdGlvbiBvZiB0aGUgaHR0cHM6Ly9kZXZlbG9wZXIuc2FsZXNmb3JjZS5jb20vZG9jcy9hdGxhcy5lbi11cy5zZmR4X2Rldi5tZXRhL3NmZHhfZGV2L3NmZHhfZGV2X2F1dGhfd2ViX2Zsb3cuaHRtLiIKICBdCn0KCg=='
    $result = Connect-SfAuthBase64 -Base64 $SDX_AUTH_URL

    Assert-AreEqual -Expected "me@contoso.com" -Presented $result
}