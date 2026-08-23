<#
.SYNOPSIS
    Displays IPv6 binding status for network adapters.
#>

Get-NetAdapter |
    Where-Object Status -ne "Disabled" |
    ForEach-Object {

        $Adapter = $_

        $IPv6 = Get-NetAdapterBinding `
            -Name $Adapter.Name `
            -ComponentID ms_tcpip6 `
            -ErrorAction SilentlyContinue

        [PSCustomObject]@{
            Adapter     = $Adapter.Name
            Status      = $Adapter.Status
            MacAddress  = $Adapter.MacAddress
            IPv6Enabled = $IPv6.Enabled
        }
    } |
    Format-Table -AutoSize
