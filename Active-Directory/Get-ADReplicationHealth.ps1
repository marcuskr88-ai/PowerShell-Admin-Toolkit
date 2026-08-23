<#
.SYNOPSIS
    Performs basic Active Directory replication health checks.

.DESCRIPTION
    Queries domain controllers and displays replication failures,
    replication partner information, and basic DC availability.

.NOTES
    Designed as a general administrative troubleshooting utility.
#>

Import-Module ActiveDirectory -ErrorAction Stop

Write-Host "`nActive Directory Replication Health Check" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Get all domain controllers
$DomainControllers = Get-ADDomainController -Filter *

Write-Host "`nDomain Controllers:" -ForegroundColor Yellow

$DomainControllers |
    Select-Object HostName, IPv4Address, Site, OperatingSystem |
    Format-Table -AutoSize

Write-Host "`nReplication Failures:" -ForegroundColor Yellow

$Failures = Get-ADReplicationFailure -Target * -Scope Forest

if ($Failures) {
    $Failures |
        Select-Object Server, Partner, FirstFailureTime,
            FailureCount, LastError |
        Format-Table -AutoSize
}
else {
    Write-Host "No replication failures detected." -ForegroundColor Green
}

Write-Host "`nReplication Partner Metadata:" -ForegroundColor Yellow

Get-ADReplicationPartnerMetadata `
    -Target * `
    -Scope Domain |
    Select-Object Server, Partner,
        LastReplicationSuccess,
        ConsecutiveReplicationFailures |
    Format-Table -AutoSize

Write-Host "`nTesting Domain Controller Connectivity:" -ForegroundColor Yellow

foreach ($DC in $DomainControllers) {

    $Online = Test-Connection `
        -ComputerName $DC.HostName `
        -Count 1 `
        -Quiet

    [PSCustomObject]@{
        DomainController = $DC.HostName
        IPAddress        = $DC.IPv4Address
        Site             = $DC.Site
        Reachable        = $Online
    }
}
