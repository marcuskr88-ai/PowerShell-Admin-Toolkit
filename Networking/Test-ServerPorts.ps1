<#
.SYNOPSIS
    Tests TCP connectivity to a remote server on common infrastructure ports.

.PARAMETER ComputerName
    Hostname or IP address to test.

.EXAMPLE
    .\Test-ServerPorts.ps1 -ComputerName "server01.contoso.com"
#>

param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

$Ports = @{
    DNS       = 53
    Kerberos  = 88
    RPC       = 135
    LDAP      = 389
    SMB       = 445
    LDAPS     = 636
    GC        = 3268
    GCSSL     = 3269
    WinRM     = 5985
    RDP       = 3389
}

$Results = foreach ($Service in $Ports.GetEnumerator()) {

    $Test = Test-NetConnection `
        -ComputerName $ComputerName `
        -Port $Service.Value `
        -WarningAction SilentlyContinue

    [PSCustomObject]@{
        Service = $Service.Key
        Port    = $Service.Value
        Server  = $ComputerName
        Success = $Test.TcpTestSucceeded
    }
}

$Results |
    Sort-Object Port |
    Format-Table -AutoSize
