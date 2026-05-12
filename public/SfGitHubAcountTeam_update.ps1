Set-MyInvokeCommandAlias -Alias "sfDataUpdateGitHubAccountTeam" -Command 'Invoke-SfDataUpdateGitHubAccountTeam -UserId {userid} -RecordId {recordid}'

function Update-SfGithubAccountTeam{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$RecordId,
        [Parameter(Mandatory,Position=0)][string]$UserHandle
    )

    # Get id from Url or id

    $user = Get-SfUserByHandle -Handle $UserHandle

    if(-not $user){
        throw "User with handle $UserHandle not found"
    }
    $UserId = $user.Id

    $params = @{
        recordid = $RecordId
        userid = $UserId
    }

    $ret = Invoke-MyCommand -Command "sfDataUpdateGitHubAccountTeam" -Parameters $params

    return $ret
} Export-ModuleMember -Function Update-SfGithubAccountTeam

function Invoke-SfDataUpdateGitHubAccountTeam{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RecordId,
        [Parameter(Mandatory)][string]$UserId
    )

    $command = 'sf data update record --sobject GitHub_Account_Teams__c --record-id {recordid} --values "User__c=''{userid}'' "'

    $command = $command -replace "{recordid}", $RecordId
    $command = $command -replace "{userid}", $UserId

    Write-MyDebug " >> $command" -section "SfDataCreate"
    
    $response = Invoke-Expression $command
    
    Write-MyDebug " << $command" -section "SfDataCreate"
    
    Write-MyDebug "Response" -section "SfDataCreate" -Object $response

    return $response

} Export-ModuleMember -Function Invoke-SfDataUpdateGitHubAccountTeam