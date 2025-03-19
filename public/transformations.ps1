function Edit-AttributeValueFromHTML{
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory,Position=0)][string]$AttributeName,
        [Parameter(Mandatory,Position=1)][string]$NewAttributeName,
        [Parameter(Mandatory,ValueFromPipeline,Position=2)][object]$Object,
        [Parameter()][switch] $RemoveOriginalAttribute
    )

    process{

        # Check if the attribute exists in the object
        if($null -eq $Object.$AttributeName) {
            "Attribute $AttributeName is not found in object $($object.id)" | Write-Warning
            return $Object
        }

        $value = Get-OwnerNameFromHtml -html $($Object.$AttributeName)

        # return if value is null
        if ($null -eq $value) {
            "Attribute $AttributeName is not found or empty in object $($object.id)" | Write-Warning
            return $Object
        }

        # Add the new attribute
        $object.$NewAttributeName = $value

        # Remove the original attribute if specified
        if ($RemoveOriginalAttribute) {
             $Object.Remove($AttributeName)
        }

        return $Object
    }

}

# Function to extract Owner Name from HTML
function Get-OwnerNameFromHtml {
    param (
        [string]$html
    )

    if ([string]::IsNullOrEmpty($html)) {
        return ""
    }

    if ($html -match '<a[^>]*>([^<]+)</a>') {
        return $matches[1]
    }
    return $null
}