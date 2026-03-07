function Mock_SfDataQuery {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$attrib,
        [Parameter(Mandatory = $true)][string]$type,
        [Parameter(Mandatory = $true)][string]$id,
        [Parameter(Mandatory = $true)][string]$filename

    )

                # sf data query --query "SELECT {attributes} FROM {type} WHERE Id='{id}'" -r=json
    # $command = 'sf data query --query "SELECT {attributes} FROM {type} WHERE Id=''{id}''" -r=json'
    $command = 'Invoke-SfDataQuery -Type {type} -Id {id} -Attributes "{attributes}"'
    $command = $command -replace "{attributes}", $attrib
    $command = $command -replace "{type}", $type
    $command = $command -replace "{id}", $id
    MockCall -Command $command -filename $filename
}

#sf data query --query "SELECT Id,Name,OwnerId FROM opportunity WHERE Id='0065c00001SFRbYAAX'" -r=json
#sf data query --query "SELECT Id,Name FROM Opportunity WHERE Id='0065c00001SFRbYAAX'" -r=json

# Invoke-SfDataQuery -Type {type} -Id {id} -Attributes "{attributes}"

function Mock_SfDataQueryWithWhere {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$attrib,
        [Parameter(Mandatory = $true)][string]$from,
        [Parameter(Mandatory = $true)][string]$where,
        [Parameter(Mandatory = $true)][string]$filename
    )

    $command = 'Invoke-SfDataQueryWithWhere -From {from} -Where "{where}" -Attributes "{attributes}"'
    $command = $command -replace "{attributes}", $attrib
    $command = $command -replace "{from}", $from
    $command = $command -replace "{where}", $where
    MockCall -Command $command -filename $filename
}

function Mock_SfDataQueryWithWhere_User_rulasg{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string[]]$AdditionalAttributes
    )

    $attrib = "Id,Name,GitHub_Username__c,Email,Department,ManagerId,Username,Title"
    $from = "User"
    $where = "GitHub_Username__c='rulasg'"
    $filename = "sf-data-querywithwhere-user_rulasg.json"

    if ($AdditionalAttributes) {
        $attrib += "," + ($AdditionalAttributes -join ",")
    }

    Mock_SfDataQueryWithWhere -attrib $attrib -from $from -where $where -filename $filename
}