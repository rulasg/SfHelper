

function Set-SfGitHubAccountTeam{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$SfUrl,
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)][Alias("sf_Id")][string]$AccountId,
        [Parameter(Position=0)][string]$UserHandle,
        [Parameter(Position=0)][ValidateSet("Solutions Engineer")][string]$TeamMemberRole,
        [switch]$Force
    )

    process{

        $id = Resolve-AccountId -SfUrl $SfUrl -AccountId $AccountId -Throw
        
        $accountTeams = Get-SfGithubAccountTeam -AccountId $id -AsHashTable -Force:$Force
        
        # Check if there is a record of the TeammemberRole
        if(-not $accountTeams.$TeamMemberRole){
            Write-MyDebug "No existing team member with role $TeamMemberRole found. Creating new team member." -Section "Set-SfGitHubAccountTeam"
            New-SfGithubAccountTeam -SfUrl $SfUrl -AccountId $AccountId -UserHandle $UserHandle -TeamMemberRole $TeamMemberRole
            $ret = $true
        } else {
            # Check if the actual value is already the one we want to set. If yes, do nothing. If not, update it.
            if($accountTeams.$TeamMemberRole.userHandle -contains $UserHandle){
                Write-MyDebug "Team member with role $TeamMemberRole already has the correct user handle $UserHandle. No update needed." -Section "Set-SfGitHubAccountTeam"
                Write-MyWarning "UserHandle[$UserHandle] already set for TeamMemberRole[$TeamMemberRole]. Skipping update."
                $ret = $false
            } else{
                if($accountTeams.$TeamMemberRole.userHandle.Count -gt 1){
                    # More than one record with the same TeamMemberRole. 
                    Write-MyDebug "More than one team member with role $TeamMemberRole found. Cannot determine which one to update. Adding new team member instead." -Section "Set-SfGitHubAccountTeam"
                    Write-MyWarning "More than one UserHandle found for TeamMemberRole[$TeamMemberRole]. Adding new team member instead of updating."
                    New-SfGithubAccountTeam -SfUrl $SfUrl -AccountId $AccountId -UserHandle $UserHandle -TeamMemberRole $TeamMemberRole
                    $ret = $true
                } else {
                    # Update existing record
                    $recordId = $accountTeams.$TeamMemberRole.Id
                    Write-MyDebug "Existing team member with role $TeamMemberRole found. Updating team member." -Section "Set-SfGitHubAccountTeam"
                    Update-SfGithubAccountTeam -RecordId $recordId -UserHandle $UserHandle
                    $ret = $true
                }
            }
        }
        
        if($ret){
            "Updated account team member for AccountId $AccountId. Resetting cache." | Write-MyDebug -Section "Set-SfGitHubAccountTeam"
            Reset-SfGithubAccountTeamCache -AccountId $id
        }
    }

} Export-ModuleMember -Function Set-SfGitHubAccountTeam

# Sample: rulasg - 0055c000009T2o8AAC
# Sample account url : https://github.lightning.force.com/lightning/r/Account/0015c00002VbY47AAF/view


