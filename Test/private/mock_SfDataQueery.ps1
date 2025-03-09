function Mock_SfDataQuery {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$attrib,
        [Parameter(Mandatory = $true)][string]$type,
        [Parameter(Mandatory = $true)][string]$id,
        [Parameter(Mandatory = $true)][string]$filename

    )

    $command = 'sf data query --query "SELECT {attributes} FROM {type} WHERE Id=''{id}''" -r=json'
    $command = $command -replace "{attributes}", $attrib
    $command = $command -replace "{type}", $type
    $command = $command -replace "{id}", $id
    MockCall -Command $command -filename $filename
}

#sf data query --query "SELECT Id,Name,OwnerId FROM opportunity WHERE Id='0065c00001SFRbYAAX'" -r=json
#sf data query --query "SELECT Id,Name FROM Opportunity WHERE Id='0065c00001SFRbYAAX'" -r=json