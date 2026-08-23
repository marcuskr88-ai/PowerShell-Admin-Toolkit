<#
.SYNOPSIS
    Restarts a Windows service on a remote computer.

.PARAMETER ComputerName
    Target computer.

.PARAMETER ServiceName
    Windows service name.

.EXAMPLE
    .\Restart-RemoteService.ps1 `
        -ComputerName "server01" `
        -ServiceName "w32time"
#>

param(
    [Parameter(Mandatory)]
    [string]$ComputerName,

    [Parameter(Mandatory)]
    [string]$ServiceName
)

try {

    $Service = Get-Service `
        -ComputerName $ComputerName `
        -Name $ServiceName `
        -ErrorAction Stop

    Write-Host "Current status: $($Service.Status)"

    if ($Service.Status -eq "Running") {

        Restart-Service `
            -InputObject $Service `
            -Force `
            -ErrorAction Stop

    }
    else {

        Start-Service `
            -InputObject $Service `
            -ErrorAction Stop
    }

    Start-Sleep -Seconds 3

    $UpdatedService = Get-Service `
        -ComputerName $ComputerName `
        -Name $ServiceName

    Write-Host `
        "$ServiceName is now $($UpdatedService.Status)" `
        -ForegroundColor Green
}
catch {

    Write-Error "Unable to restart service: $($_.Exception.Message)"
}
