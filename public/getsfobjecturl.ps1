function Get-SfObjectUrl{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName, Position=0)][string]$Id
    )

    return "https://github.my.salesforce.com/$Id"

} Export-ModuleMember -Function Get-SfObjectUrl

function Open-SfObject{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ValueFromPipeline, Position=0)][string]$Id
    )

    $url = Get-SfObjectUrl -Id $Id

    "Opening Sf Url $url" | Write-MyDebug -Section "Open-SfObject"

    Open-Url $url

} Export-ModuleMember -Function Open-SfObject