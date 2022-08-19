<#
.SYNOPSIS
    Creates Dynamic Azure AD groups based on user properties.
    Given a set of user properties, the cmdlet generate a dynamic group for each
    value of each property.

.PARAMETER UserProperties
    List of user properties.

.NOTES
    This cmdlet is meant for sample purposes only.ara
    The cmdlet requires AzureADPreview module.
  
.EXAMPLE
    Update-DynamicGroups "JobTitle", "Department"
#>

param([Parameter(Mandatory = $true)][string[]]$UserProperties)

#$UserProperties = "JobTitle", "Department"

# Generate the group name based on user property name and value
function Get-GroupName {
    param (
        [String] $PropertyName,
        [String] $PropertyValue
    )

    return "DynGrp$PropertyName$PropertyValue" -replace "[^A-Za-z0-9'.\-_!#^~]","_"
}

# Get distinct values for the specified user property
function Get-PropertyValues {
    param (
        [String] $PropertyName
    )

    $PropertyName = $_.ToString()
    (Get-AzureADUser `
    | Select-Object @{Name = 'Value'; Expression = $PropertyName } `
    | Where-Object { $null -ne $_.Value }).Value `
    | Group-Object `
    | ForEach-Object {
        $_.Name.ToString()
    }
}

# Main loop
$UserProperties | ForEach-Object {
    $PropertyName = $_
    Write-Host "Processing property $PropertyName"
    Get-PropertyValues -PropertyName $PropertyName | ForEach-Object {
        $PropertyValue = $_
        $GroupName = Get-GroupName `
            -PropertyName $PropertyName `
            -PropertyValue $PropertyValue
        
        if ($null -eq (Get-AzureAdMSGroup -Filter "DisplayName eq '$GroupName'")) {
            Write-Host "Creating group $GroupName"

            New-AzureADMSGroup `
                -DisplayName $GroupName `
                -Description "Dynamic group for user property $PropertyName=$PropertyValue" `
                -SecurityEnabled $true `
                -MailEnabled $false `
                -MailNickname $GroupName `
                -GroupTypes "DynamicMembership" `
                -MembershipRule "(user.$PropertyName -eq ""$PropertyValue"")" `
                -MembershipRuleProcessingState "On" `
                | Out-Null
        }
        else {
            Write-Host "Group $GroupName already exists"
        }
    }
}
