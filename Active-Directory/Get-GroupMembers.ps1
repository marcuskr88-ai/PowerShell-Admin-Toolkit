<#
.SYNOPSIS
    Displays members of an Active Directory group.

.PARAMETER GroupName
    Name of the Active Directory group to query.

.EXAMPLE
    .\Get-GroupMembers.ps1 -GroupName "IT Administrators"
#>

param(
    [Parameter(Mandatory)]
    [string]$GroupName
)

Import-Module ActiveDirectory -ErrorAction Stop

try {

    Get-ADGroupMember `
        -Identity $GroupName `
        -Recursive |
        Get-ADUser `
            -Properties DisplayName, EmailAddress, Enabled |
        Select-Object `
            SamAccountName,
            DisplayName,
            EmailAddress,
            Enabled |
        Sort-Object DisplayName |
        Format-Table -AutoSize

}
catch {
    Write-Error "Unable to retrieve group members: $($_.Exception.Message)"
}
