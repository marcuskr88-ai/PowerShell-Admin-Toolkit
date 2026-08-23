<#
.SYNOPSIS
    Searches domain controllers for recent account lockout events.

.PARAMETER Username
    SamAccountName of the user to investigate.

.PARAMETER Hours
    Number of hours of Security log history to search.

.EXAMPLE
    .\Get-AccountLockoutSource.ps1 -Username "jsmith" -Hours 24
#>

param(
    [Parameter(Mandatory)]
    [string]$Username,

    [int]$Hours = 24
)

Import-Module ActiveDirectory -ErrorAction Stop

$StartTime = (Get-Date).AddHours(-$Hours)

$DomainControllers = Get-ADDomainController -Filter *

$Results = foreach ($DC in $DomainControllers) {

    try {

        Get-WinEvent `
            -ComputerName $DC.HostName `
            -FilterHashtable @{
                LogName   = "Security"
                Id        = 4740
                StartTime = $StartTime
            } `
            -ErrorAction Stop |
        ForEach-Object {

            $Xml = [xml]$_.ToXml()

            $Data = @{}

            foreach ($Item in $Xml.Event.EventData.Data) {
                $Data[$Item.Name] = $Item.'#text'
            }

            if ($Data.TargetUserName -ieq $Username) {

                [PSCustomObject]@{
                    TimeCreated    = $_.TimeCreated
                    User           = $Data.TargetUserName
                    CallerComputer = $Data.CallerComputerName
                    DomainController = $DC.HostName
                }
            }
        }

    }
    catch {
        Write-Warning "Unable to query $($DC.HostName)"
    }
}

$Results |
    Sort-Object TimeCreated -Descending |
    Format-Table -AutoSize
