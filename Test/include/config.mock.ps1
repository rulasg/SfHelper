
$INVOKE_GETCONFIGROOTPATH = "Invoke-SfGetConfigRootPath"

function Mock_Config{
    param(
        [Parameter(Position=0)][string] $key = "config",
        [Parameter(Position=1)][object] $Config
    )

    $MOCK_CONFIG_PATH = "test_config_path"

    # Remove mock config path if exists
    if(Test-Path $MOCK_CONFIG_PATH){
        Remove-Item -Path $MOCK_CONFIG_PATH -ErrorAction SilentlyContinue -Recurse -Force
    }

    # create mock config path
    New-Item -Path $MOCK_CONFIG_PATH -ItemType Directory -Force

    # if $config is not null save it to a file
    if($null -ne $Config){
        $configfile = Join-Path -Path $MOCK_CONFIG_PATH -ChildPath "$key.json"
        $Config | ConvertTo-Json -Depth 10 | Set-Content $configfile
    }

    # Mock invoke call
    MockCallToString $INVOKE_GETCONFIGROOTPATH -OutString $MOCK_CONFIG_PATH

}