Set-MyInvokeCommandAlias -Alias "sfDataCreateGitHubAccountTeam" -Command 'Invoke-SfDataCreateGitHubAccountTeam -AccountId {accountid} -UserId {userid} -TeamMemberRole "{teammemberrole}"'

function New-SfGithubAccountTeam{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$SfUrl,
        [Parameter()][string]$AccountId,
        [Parameter(Position=0)][string]$UserHandle,
        [Parameter(Position=0)][ValidateSet("Solutions Engineer")][string]$TeamMemberRole
    )

    # Get id from Url or id
    $AccountId = [string]::IsNullOrWhiteSpace($AccountId) ? $(Get-SfObjectIdFromUrl -SfUrl $SfUrl) : $AccountId

    $user = Get-SfUserByHandle -Handle $UserHandle

    if(-not $user){
        throw "User with handle $UserHandle not found"
    }
    $UserId = $user.Id

    #check that $id has value
    if ([string]::IsNullOrWhiteSpace($AccountId)){
        throw "Id is required. Could not extract from URL $SfUrl"
    }

    $params = @{
        accountid = $AccountId
        userid = $UserId
        teammemberrole = $TeamMemberRole
    }

    $ret = Invoke-MyCommand -Command "sfDataCreateGitHubAccountTeam" -Parameters $params

    return $ret
}

function Invoke-SfDataCreateGitHubAccountTeam{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$AccountId,
        [Parameter(Mandatory)][string]$UserId,
        [Parameter(Mandatory)][ValidateSet("Solutions Engineer")][string]$TeamMemberRole
    )

    $command = 'sf data create record --sobject GitHub_Account_Teams__c --values "Account__c=''{accountid}'' User__c=''{userid}'' TeamMemberRole__c=''{teammemberrole}''"'

    $command = $command -replace "{accountid}", $AccountId
    $command = $command -replace "{userid}", $UserId
    $command = $command -replace "{teammemberrole}", $TeamMemberRole

    Write-MyDebug " >> $command" -section "SfDataCreate"
    
    $response = Invoke-Expression $command
    
    Write-MyDebug " << $command" -section "SfDataCreate"
    
    Write-MyDebug "Response" -section "SfDataCreate" -Object $response

    return $response

} Export-ModuleMember -Function Invoke-SfDataCreateGitHubAccountTeam
