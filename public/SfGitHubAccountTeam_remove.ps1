Set-MyInvokeCommandAlias -Alias "sfDataRemoveGitHubAccountTeam" -Command 'Invoke-SfDataRemoveGitHubAccountTeam -RecordId {recordid}'

function Remove-SfGithubAccountTeam{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline, Position=0)][string]$RecordId
    )

    process{

        $params = @{
            recordid = $RecordId
        }

        Invoke-MyCommand -Command "sfDataRemoveGitHubAccountTeam" -Parameters $params

    }
} Export-ModuleMember -Function Remove-SfGithubAccountTeam

function Invoke-SfDataRemoveGitHubAccountTeam{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RecordId
    )

    $command = 'sf data delete record --sobject GitHub_Account_Teams__c --record-id {recordid}'

    $command = $command -replace "{recordid}", $RecordId

    Write-MyDebug " >> $command" -section "SfDataRemove"
    
    $response = Invoke-Expression $command
    
    Write-MyDebug " << $command" -section "SfDataRemove"
    
    Write-MyDebug "Response" -section "SfDataRemove" -Object $response

    return $response

} Export-ModuleMember -Function Invoke-SfDataRemoveGitHubAccountTeam