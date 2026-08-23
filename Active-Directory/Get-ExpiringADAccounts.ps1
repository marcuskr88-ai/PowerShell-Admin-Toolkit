<#
.SYNOPSIS
    Finds enabled Active Directory accounts approaching expiration.

.PARAMETER Days
    Number of days ahead to search.

.EXAMPLE
    .\Get-ExpiringADAccounts.ps1 -Days 30
#>

param(
    [int]$Days = 30
)

Import-Module ActiveDirectory -ErrorAction Stop

$Today = Get-Date
$Cutoff = $Today.AddDays($Days)

Get-ADUser `
    -Filter {
        Enabled -eq $true -and
        AccountExpirationDate -like "*"
    } `
    -Properties DisplayName,
                AccountExpirationDate,
                EmailAddress |
Where-Object {
    $_.AccountExpirationDate -ge $Today -and
    $_.AccountExpirationDate -le $Cutoff
} |
Select-Object SamAccountName,
              DisplayName,
              EmailAddress,
              AccountExpirationDate,
              @{Name="DaysRemaining";Expression={
                  [math]::Ceiling(
                      ($_.AccountExpirationDate - $Today).TotalDays
                  )
              }} |
Sort-Object AccountExpirationDate |
Format-Table -AutoSize
