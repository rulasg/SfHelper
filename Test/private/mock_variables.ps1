
# Required for INVOKE COMMAND MOCK

$MODULE_INVOKATION_TAG = "SfHelperModule"
$MODULE_INVOKATION_TAG_MOCK = "SfHelperModule-Mock"

# SetMockPath
$MOCK_PATH = $PSScriptRoot | Split-Path -Parent | Join-Path -ChildPath 'private' -AdditionalChildPath 'mocks'