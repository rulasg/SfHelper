function Get-SfGithubAccountTeamAccountTeam{
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
        # "User.GitHub_Username__c",
        "User__c",
        "TeamMemberRole__c",
        "Id"
    )

    try{

        # Get object
        # $response = Get-SfDataQuery -Type "GitHub_Account_Teams__c" -Id $Id -Attributes $attributes -Force:$Force
        $response = Get-SfDataQueryWithWhere -From "GitHub_Account_Teams__c" -Where "Account__c='$Id'" -Attributes $attributes -Name "Get-SfGithubAccountTeamAccountTeam" -Force:$Force

        $ret = $response | NormalizeResponse2
        
        return [PSCustomObject] $ret
    } catch{
        "Something went wrong while getting Account Team Member for Id $Id. Error: $($_.Exception.Message)" | Write-MyDebug -Section "Get-SfAccountTeamMember"
    }

} Export-ModuleMember -Function Get-SfGithubAccountTeamAccountTeam

function NormalizeResponse2{
    param(
        [Parameter(ValueFromPipeline, Position=0)][object]$ResponseItem
    )
        
    begin{
        $ret = @{}
    }
    
    process {
        
        # Role
        $role = $ResponseItem.TeamMemberRole__c -replace " ", "_"

        $userId = $ResponseItem.User__c

        if ($userId){

            $user = Get-SfUser -Id $ResponseItem.User__c
            
            $username = $user.GitHub_Username__c

        } else {
            $username = $null
        }

        if(-not $($ret.$role)){
            $ret.$role = $username
        } else {
            # Add the new name to the actual string
            # this will allow assigning more than one SE to an account
            # throw "Multiple users with the same role [$($ResponseItem.TeamMemberRole)] found. This is not expected. Please check the data and try again."
            $ret.$role += ";$username"
        }
    }

    end{
        return $ret
    }
}