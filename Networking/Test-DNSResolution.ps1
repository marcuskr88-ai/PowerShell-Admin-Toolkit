<#
.SYNOPSIS
    Performs DNS resolution tests against configured DNS servers.

.PARAMETER HostName
    DNS name to resolve.

.EXAMPLE
    .\Test-DNSResolution.ps1 -HostName "server01.contoso.com"
#>

param(
    [Parameter(Mandatory)]
    [string]$HostName
)

$DNSServers = Get-DnsClientServerAddress `
    -AddressFamily IPv4 |
    Where-Object ServerAddresses |
    Select-Object -ExpandProperty ServerAddresses `
    -Unique

foreach ($Server in $DNSServers) {

    Write-Host "`nTesting DNS server $Server" -ForegroundColor Cyan

    try {

        Resolve-DnsName `
            -Name $HostName `
            -Server $Server `
            -ErrorAction Stop |
        Select-Object Name,
                      Type,
                      IPAddress,
                      NameHost |
        Format-Table -AutoSize

    }
    catch {

        Write-Warning "Resolution failed using $Server"
    }
}
