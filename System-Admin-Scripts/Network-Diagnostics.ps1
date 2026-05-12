# Network Diagnostics and Troubleshooting
# Comprehensive network troubleshooting toolkit

<#
.SYNOPSIS
    Network diagnostics and connectivity testing tools

.DESCRIPTION
    Provides tools for:
    - Testing network connectivity
    - DNS resolution testing
    - Ping diagnostics
    - Route information
    - Network adapter configuration
    - Firewall rules

.EXAMPLE
    . .\Network-Diagnostics.ps1
    Test-NetworkConnectivity
    Test-DNSResolution -Hostname "google.com"
    Get-NetworkAdapterInfo

.NOTES
    Requires: Administrator privileges
    Author: Windows Admin Toolkit
#>

function Test-NetworkConnectivity {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$ComputerName = "8.8.8.8",
        
        [Parameter(Mandatory=$false)]
        [int]$Timeout = 4000
    )

    try {
        Write-Host "Testing connectivity to $ComputerName..." -ForegroundColor Cyan
        $result = Test-NetConnection -ComputerName $ComputerName -WarningAction SilentlyContinue
        
        Write-Host "ComputerName: $($result.ComputerName)" -ForegroundColor Green
        Write-Host "RemoteAddress: $($result.RemoteAddress)" -ForegroundColor Green
        Write-Host "PingSucceeded: $($result.PingSucceeded)" -ForegroundColor $(if ($result.PingSucceeded) { "Green" } else { "Red" })
        Write-Host "PingReplyDetails: $($result.PingReplyDetails.Status)" -ForegroundColor Gray
    }
    catch {
        Write-Host "Error testing connectivity: $_" -ForegroundColor Red
    }
}

function Test-DNSResolution {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Hostname
    )

    try {
        Write-Host "Testing DNS resolution for $Hostname..." -ForegroundColor Cyan
        $result = Resolve-DnsName -Name $Hostname -ErrorAction Stop
        
        Write-Host "Name: $($result.Name)" -ForegroundColor Green
        $result | Format-Table -Property Name, Type, IPAddress -AutoSize
    }
    catch {
        Write-Host "DNS resolution failed: $_" -ForegroundColor Red
    }
}

function Get-NetworkAdapterInfo {
    [CmdletBinding()]
    param()

    try {
        Write-Host "=" * 80
        Write-Host "Network Adapter Information" -ForegroundColor Cyan
        Write-Host "=" * 80

        Get-NetAdapter | Format-Table -Property Name, InterfaceDescription, Status, MacAddress -AutoSize
        
        Write-Host "\n" + "=" * 80
        Get-NetIPAddress | Format-Table -Property InterfaceAlias, AddressFamily, IPAddress -AutoSize
    }
    catch {
        Write-Host "Error retrieving network adapter info: $_" -ForegroundColor Red
    }
}

function Get-RouteInfo {
    [CmdletBinding()]
    param()

    try {
        Write-Host "=" * 80
        Write-Host "Network Routes" -ForegroundColor Cyan
        Write-Host "=" * 80

        Get-NetRoute -AddressFamily IPv4 | Format-Table -Property DestinationPrefix, NextHop, RouteMetric, ifIndex -AutoSize
    }
    catch {
        Write-Host "Error retrieving route info: $_" -ForegroundColor Red
    }
}

# Execute diagnostics
Test-NetworkConnectivity
