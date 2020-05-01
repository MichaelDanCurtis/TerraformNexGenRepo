function Get-GroupObjectId {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [string]$GroupName
    )

    begin {
    }

    process {

        $Group = (Get-AzADGroup -DisplayName $GroupName)
        if ($null -ne $Group) {
            $GroupId = $Group.Id.Guid
        }
        else {
            Throw "Group $GroupName not found in current tenant"
        }

        return $GroupId
    }

    end {
    }
}