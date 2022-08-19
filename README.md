# Update-DynamicGroups

Update-DynamicGroups is a sample PowerShell script that generates Azure AD Dynamic Groups based on arbitrary user properties.

Given a set of user properties, the script generates a Dynamic Group for each property value, assigning membership based on the property value.

Per example, for the JobTitle and Department properties, the script generates groups like these:

- DynGrpJobTitleSoftware_Engineer
- DynGrpJobTitleMarketing_Manager
- DynGrpJobTitleAdministrative_Assistant
- DynGrpJobTitleConsultant
- DynGrpDepartmentMarketing
- DynGrpDepartmentServices

The membership of each group is set dynamically using a condition based on the property value.
Per example:

```text
user.JobTitle -eq "Software Engineer"
```

For more information see [Dynamic membership rules for groups in Azure Active Directory](https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/groups-dynamic-membership).

## Requirements

The script requires the [AzureADPreview](https://www.powershellgallery.com/packages/AzureADPreview) module.

## Usage

For details about the usage of the script, invoke `Get-Help`.

```PowerShell
Get-Help ./Update-DynamicGroups.ps1
```

## Additional notes

The naming convention for the group names is the combination of:

- "DynGrp"
- User property name
- User property value

Invalid characters are replaced by an underscore.

The naming convention can be customized by altering the `Get-GroupName` function.
