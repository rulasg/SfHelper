Set-MyInvokeCommandAlias -Alias GetUserEmail -Command "gh api user --jq '.email'"

function Resolve-Email{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()][string]$Email
    )

    if(-not [string]::IsNullOrEmpty($Email)){
        "Resolving email [$Email] from parameter" | Write-MyVerbose
        return $Email
    }

    $Email = Invoke-MyCommand -Command GetUserEmail -ErrorAction SilentlyContinue
    "Resolved email [$Email] from github" | Write-MyVerbose

    if ($null -eq $Email){
        throw "Unable to resolve user email. Please provide email as parameter or set proper gh cli credentials and user github profile email." | Write-MyError
    }

    return $Email

} Export-ModuleMember -Function Resolve-Email