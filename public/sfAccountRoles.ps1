Set-MyInvokeCommandAlias -Alias "sfDataCreateAccountTeamMember" -Command  'Invoke-SfDataCreateAccountTeamMember -AccountId {accountid} -UserId {userid} -TeamMemberRole "{teammemberrole}"'

function Get-SfAccountRole{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$SfUrl,
        [Parameter()][string]$Id,
        [switch]$Force
    )

    # Get ig from Url or id
    $id = [string]::IsNullOrWhiteSpace($Id) ? $(Get-SfObjectIdFromUrl -SfUrl $SfUrl) : $Id


    #check that $id has value
    if ([string]::IsNullOrWhiteSpace($Id)){
        throw "Id is required. Could not extract from URL $SfUrl"
    }

    $attributes = @(
        "User.GitHub_Username__c",
        "TeamMemberRole"
    )

    # Get object
    $response = Get-SfDataQuery -Type "AccountTeamMember" -Id $Id -Attributes $attributes -Force:$Force

    $ret = $response | NormalizeResponse

    return $ret
} Export-ModuleMember -Function Get-SfAccountRole


function NormalizeResponse{
    param(
        [Parameter(ValueFromPipeline, Position=0)][object]$ResponseItem
        )
        
        begin{
            $ret = @{}
        }
        
        process {
            
            $role = $ResponseItem.TeamMemberRole -replace " ", "_"
            $username = $ResponseItem.User.GitHub_Username__c
            
            $ret.$role = $username
            
        }
        end{
            return $ret
        }
    }
    
function Set-SfAccountRole{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$SfUrl,
        [Parameter()][string]$AccountId,
        [Parameter(Position=0)][string]$UserId,
        [Parameter(Position=0)][ValidateSet("Solutions Engineer")][string]$TeamMemberRole
    )

    # Get ig from Url or id
    $AccountId = [string]::IsNullOrWhiteSpace($AccountId) ? $(Get-SfObjectIdFromUrl -SfUrl $SfUrl) : $AccountId


    #check that $id has value
    if ([string]::IsNullOrWhiteSpace($AccountId)){
        throw "Id is required. Could not extract from URL $SfUrl"
    }

    $params = @{
        accountid = $AccountId
        userid = $UserId
        teammemberrole = $TeamMemberRole
    }

    $ret = Invoke-MyCommand -Command "sfDataCreateAccountTeamMember" -Parameters $params

    return $ret
} Export-ModuleMember -Function Set-SfAccountRole

# Sample: rulasg - 0055c000009T2o8AAC
# Sample account url : https://github.lightning.force.com/lightning/r/Account/0015c00002VbY47AAF/view

function Invoke-SfDataCreateAccountTeamMember{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$AccountId,
        [Parameter(Mandatory)][string]$UserId,
        [Parameter(Mandatory)][ValidateSet("Solutions Engineer")][string]$TeamMemberRole
    )

    $command = 'sf data create record --sobject AccountTeamMember --values "AccountId=''{accountid}'' UserId=''{userid}'' TeamMemberRole=''{teammemberrole}''"'

    $command = $command -replace "{accountid}", $AccountId
    $command = $command -replace "{userid}", $UserId
    $command = $command -replace "{teammemberrole}", $TeamMemberRole

    Write-MyDebug " >> $command" -section "SfDataCreate"
    
    $response = Invoke-Expression $command
    
    Write-MyDebug " << $command" -section "SfDataCreate"
    
    Write-MyDebug "Response" -section "SfDataCreate" -Object $response

    return $response

} Export-ModuleMember -Function Invoke-SfDataCreateAccountTeamMember