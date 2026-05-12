function Get-SfGithubAccountTeam{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$SfUrl,
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)][Alias("sf_Id")][string]$AccountId,
        [switch]$Force,
        [switch]$AsHashTable
    )

    process {

        # Get id from Url or AccountId
        $id = Resolve-AccountId -SfUrl $SfUrl -AccountId $AccountId -Throw
        
        $attributes = @(
            # "User.GitHub_Username__c",
            "User__c",
            "TeamMemberRole__c",
            "Id"
        )
            
        try{
            
            # Get object
            # $response = Get-SfDataQuery -Type "GitHub_Account_Teams__c" -Id $Id -Attributes $attributes -Force:$Force
            $response = Get-SfDataQueryWithWhere -From "GitHub_Account_Teams__c" -Where "Account__c='$Id'" -Attributes $attributes -Name $id -Force:$Force
            
            if ($AsHashTable){
                $ret = $response | NormalizeResponse3
            } else {
                $norm = $response | NormalizeResponse2
                $ret = [PSCustomObject] $norm
            }
            
            return $ret
            
        } catch{
            "Something went wrong while getting Account Team Member for Id $Id. Error: $($_.Exception.Message)" | Write-MyDebug -Section "Get-SfAccountTeamMember"
        }
    }

} Export-ModuleMember -Function Get-SfGithubAccountTeam

function Reset-SfGithubAccountTeamCache{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$SfUrl,
        [Parameter()][string]$AccountId,
        [switch]$Force,
        [switch]$AsHashTable
    )

    # Get id from Url or AccountId
    $id = Resolve-AccountId -SfUrl $SfUrl -AccountId $AccountId -Throw

    $attributes = @(
        # "User.GitHub_Username__c",
        "User__c",
        "TeamMemberRole__c",
        "Id"
    )
    
    Reset-SfDataQueryWithWhereCache -From "GitHub_Account_Teams__c" -Where "Account__c='$Id'" -Attributes $attributes -Name $AccountId

}

function NormalizeResponse3{
    param(
        [Parameter(ValueFromPipeline, Position=0)][object]$ResponseItem
    )

    begin{
        $ret = @{}
    }

    process{

        $role = $ResponseItem.TeamMemberRole__c
        $userId = $ResponseItem.User__c
        if($userId){
            $user = Get-SfUser -Id $ResponseItem.User__c
            $userHandle = $user.GitHub_Username__c
        } else {
            $userHandle = $null
        }

        if(-not $($ret.$role)){
            $ret.$role = @()
        }

         $ret.$role += @{
            UserId = $ResponseItem.User__c
            UserHandle = $userHandle
            Id = $ResponseItem.Id
            Role = $role
        }
    }

    end{
        return $ret
    }
}

function NormalizeResponse2{
    param(
        [Parameter(ValueFromPipeline, Position=0)][object]$ResponseItem
    )
        
    begin{
        $ret = @{}
    }

    process {
        
        # Role
        # $role = $ResponseItem.TeamMemberRole__c -replace " ", "_"
        $role = $ResponseItem.TeamMemberRole__c

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

function Resolve-AccountId{
    param(
        [string]$SfUrl,
        [string]$AccountId,
        [switch]$Throw
    )

    if(-Not [string]::IsNullOrWhiteSpace($AccountId)){
        return $AccountId
    }

    # Get id from Url or AccountId
    try {
        $id = Get-SfObjectIdFromUrl -SfUrl $SfUrl
        return $id
    } catch {
        if ($Throw) {
            #check that $id has value
           throw "Id is required. Check param values of AccountId [$AccountId] and SfUrl [$SfUrl]"
        }
        return $null
    }
}