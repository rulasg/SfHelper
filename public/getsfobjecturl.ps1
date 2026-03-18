function Get-SfObjectUrl{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName, Position=0)][string]$Id
    )

    return "https://github.my.salesforce.com/$Id"

} Export-ModuleMember -Function Get-SfObjectUrl

function Open-SfObject{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName, Position=0)][string]$Id
    )

    $url = Get-SfObjectUrl -Id $Id
    Open-Url -FilePath $url

} Export-ModuleMember -Function Open-SfObjectUrl