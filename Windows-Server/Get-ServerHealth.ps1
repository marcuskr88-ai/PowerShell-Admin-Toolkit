<#
.SYNOPSIS
    Performs a basic health assessment of a Windows server.
#>

$OS = Get-CimInstance Win32_OperatingSystem
$Computer = Get-CimInstance Win32_ComputerSystem

$Uptime = (Get-Date) - $OS.LastBootUpTime

Write-Host "`nServer Health Report" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan

[PSCustomObject]@{
    ComputerName = $env:COMPUTERNAME
    OperatingSystem = $OS.Caption
    UptimeDays = [math]::Round($Uptime.TotalDays, 2)
    TotalMemoryGB = [math]::Round($Computer.TotalPhysicalMemory / 1GB, 2)
    FreeMemoryGB = [math]::Round($OS.FreePhysicalMemory / 1MB, 2)
} |
Format-List

Write-Host "`nDisk Utilization:" -ForegroundColor Yellow

Get-CimInstance Win32_LogicalDisk `
    -Filter "DriveType=3" |
    Select-Object DeviceID,
        @{Name="SizeGB";Expression={
            [math]::Round($_.Size / 1GB, 2)
        }},
        @{Name="FreeGB";Expression={
            [math]::Round($_.FreeSpace / 1GB, 2)
        }},
        @{Name="FreePercent";Expression={
            [math]::Round(($_.FreeSpace / $_.Size) * 100, 2)
        }} |
    Format-Table -AutoSize

Write-Host "`nAutomatic Services Not Running:" -ForegroundColor Yellow

Get-CimInstance Win32_Service |
    Where-Object {
        $_.StartMode -eq "Auto" -and
        $_.State -ne "Running"
    } |
    Select-Object Name, DisplayName, State |
    Format-Table -AutoSize
