# PowerShell module to get the ID from a Service Fabric URL
# Allow to integrate with ProjectHelper returning SfId

function Get-SfIdFromUrl{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline, Position=0)]
        [string]$SfUrl
    )

    process{

        # Extract Id from URL
        $Id = Get-SfObjectIdFromUrl -SfUrl $SfUrl
        
        $ret = @{
            SfId = $Id
        }
        
        return $ret
    }
} Export-ModuleMember -Function Get-SfIdFromUrl