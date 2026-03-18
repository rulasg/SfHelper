function Get-SfObjectUrl{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$Id
    )

    return "https://github.my.salesforce.com/$Id"
} Export-ModuleMember -Function Get-SfObjectUrl