<#
.SYNOPSIS
    Displays routing information for a specified destination.

.PARAMETER Destination
    Destination hostname or IP address.

.EXAMPLE
    .\Get-NetworkRouteDiagnostics.ps1 -Destination "8.8.8.8"
#>

param(
    [Parameter(Mandatory)]
    [string]$Destination
)

Write-Host "`nRoute Diagnostics" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan

Write-Host "`nTarget: $Destination" -ForegroundColor Yellow

try {

    $Route = Test-NetConnection `
        -ComputerName $Destination `
        -DiagnoseRouting `
        -InformationLevel Detailed

    [PSCustomObject]@{
        Destination   = $Destination
        SourceAddress = $Route.SelectedSourceAddress
        Interface     = $Route.OutgoingInterfaceAlias
        NextHop       = $Route.SelectedNetRoute.NextHop
        RouteMetric   = $Route.SelectedNetRoute.RouteMetric
    } |
    Format-List

}
catch {
    Write-Error "Unable to perform route diagnostics."
}

Write-Host "`nCurrent IPv4 Routes:" -ForegroundColor Yellow

Get-NetRoute `
    -AddressFamily IPv4 |
    Sort-Object DestinationPrefix, RouteMetric |
    Select-Object DestinationPrefix,
                  NextHop,
                  InterfaceAlias,
                  RouteMetric |
    Format-Table -AutoSize
