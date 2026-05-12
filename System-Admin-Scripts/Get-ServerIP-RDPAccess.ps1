# Get Server IP Address for RDP Access
# This script helps identify the IP address of the current server for Remote Desktop Protocol (RDP) access

<#
.SYNOPSIS
    Retrieves server IP address information for RDP access

.DESCRIPTION
    Displays all network adapters and their IP addresses to help identify
    the correct IP for RDP connection. Includes:
    - IPv4 and IPv6 addresses
    - DHCP information
    - DNS servers
    - Default gateway
    - Network adapter details

.EXAMPLE
    . .\Get-ServerIP-RDPAccess.ps1
    Get-ServerIP
    Get-ServerIP -ShowDetails
    Connect-RDP -ComputerName "192.168.1.100" -Username "Administrator"

.NOTES
    Requires: Administrator privileges
    Author: Windows Admin Toolkit
    Date: 2026-05-12
#>

function Get-ServerIP {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$ShowDetails,
        [Parameter(Mandatory=$false)]
        [switch]$IPv4Only
    )

    try {
        Write-Host "=" * 80
        Write-Host "Server IP Address Information" -ForegroundColor Cyan
        Write-Host "=" * 80

        # Get hostname
        $hostname = [System.Net.Dns]::GetHostName()
        Write-Host "`nComputer Name: $hostname" -ForegroundColor Green

        # Get network adapter information
        $networkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

        if (-not $networkAdapters) {
            Write-Host "No active network adapters found." -ForegroundColor Yellow
            return
        }

        foreach ($adapter in $networkAdapters) {
            Write-Host "`n" + "-" * 80
            Write-Host "Adapter Name: $($adapter.Name)" -ForegroundColor Yellow
            Write-Host "Description: $($adapter.InterfaceDescription)" -ForegroundColor Gray
            Write-Host "Status: $($adapter.Status)" -ForegroundColor Green
            Write-Host "MAC Address: $($adapter.MacAddress)" -ForegroundColor Gray

            # Get IP configuration
            $ipConfig = Get-NetIPConfiguration -InterfaceIndex $adapter.InterfaceIndex

            if ($ipConfig.IPv4Address) {
                Write-Host "`nIPv4 Configuration:" -ForegroundColor Cyan
                foreach ($ip in $ipConfig.IPv4Address) {
                    Write-Host "  IP Address: $($ip.IPAddress)" -ForegroundColor Green
                    Write-Host "  Prefix Length: $($ip.PrefixLength)" -ForegroundColor Gray
                }
            }

            if (-not $IPv4Only -and $ipConfig.IPv6Address) {
                Write-Host "`nIPv6 Configuration:" -ForegroundColor Cyan
                foreach ($ip in $ipConfig.IPv6Address) {
                    Write-Host "  IP Address: $($ip.IPAddress)" -ForegroundColor Green
                }
            }

            if ($ShowDetails) {
                if ($ipConfig.IPv4DefaultGateway) {
                    Write-Host "`nDefault Gateway: $($ipConfig.IPv4DefaultGateway.NextHop)" -ForegroundColor Cyan
                }

                if ($ipConfig.DNSServer) {
                    Write-Host "`nDNS Servers:" -ForegroundColor Cyan
                    foreach ($dns in $ipConfig.DNSServer) {
                        Write-Host "  $($dns.Address)" -ForegroundColor Gray
                    }
                }

                # Get DHCP information
                $dhcpInfo = Get-NetIPInterface -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4
                if ($dhcpInfo.DHCP -eq "Enabled") {
                    Write-Host "DHCP Status: Enabled" -ForegroundColor Green
                } else {
                    Write-Host "DHCP Status: Disabled (Static IP)" -ForegroundColor Yellow
                }
            }
        }

        Write-Host "`n" + "=" * 80
        Write-Host "Use the IPv4 address above to connect via RDP" -ForegroundColor Yellow
        Write-Host "=" * 80
    }
    catch {
        Write-Host "Error retrieving IP information: $_" -ForegroundColor Red
    }
}

function Connect-RDP {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        
        [Parameter(Mandatory=$false)]
        [string]$Username,
        
        [Parameter(Mandatory=$false)]
        [int]$Port = 3389,
        
        [Parameter(Mandatory=$false)]
        [switch]$Admin
    )

    try {
        Write-Host "Attempting to connect to $ComputerName via RDP..." -ForegroundColor Cyan

        # Test connectivity first
        if (-not (Test-NetConnection -ComputerName $ComputerName -Port $Port -WarningAction SilentlyContinue).TcpTestSucceeded) {
            Write-Host "Warning: Cannot reach $ComputerName on port $Port" -ForegroundColor Yellow
            $proceed = Read-Host "Continue anyway? (Y/N)"
            if ($proceed -ne "Y") {
                return
            }
        }

        # Build RDP connection string
        $rdpFile = "$env:TEMP\RDP_$ComputerName.rdp"
        
        $rdpContent = @"
screen mode id:i:2
use multimon:i:0
desktopwidth:i:1920
desktopheight:i:1080
session bpp:i:32
compression:i:1
keyboardhook:i:2
audiomode:i:0
audioqualitymode:i:0
networkautodetect:i:1
bandwidthautodetect:i:1
displayconnectionbar:i:1
enableworkspacereconnect:i:0
disableremoteappcapscheck:i:0
allowfontsmoothing:i:1
allowdesktopcomposition:i:1
connecttoconsolesession:i:$([int]$Admin)
servername:s:$ComputerName`:$Port
loadbalanceinfo:s:
username:s:$Username
full address:s:$ComputerName`:$Port
msragg:s:0x05000806
alt tab:s:*
shell working directory:s:
authentication level:i:2
gatewayhostname:s:
gatewayusagemethod:i:4
gatewaycredentialssource:i:0
gatewayprofileusagemethod:i:1
promptcredentialonce:i:0
usedefaultgatewaycreds:i:0
"@

        Set-Content -Path $rdpFile -Value $rdpContent
        
        Write-Host "RDP configuration created at: $rdpFile" -ForegroundColor Green
        Write-Host "Launching RDP connection..." -ForegroundColor Cyan
        
        Start-Process -FilePath "mstsc.exe" -ArgumentList $rdpFile
    }
    catch {
        Write-Host "Error connecting to RDP: $_" -ForegroundColor Red
    }
}

function Get-ServerInfo-Complete {
    [CmdletBinding()]
    param()

    try {
        Write-Host "=" * 80
        Write-Host "Complete Server Information for RDP Access" -ForegroundColor Cyan
        Write-Host "=" * 80

        # OS Information
        Write-Host "`n[Operating System]" -ForegroundColor Green
        $osInfo = Get-WmiObject -Class Win32_OperatingSystem
        Write-Host "OS: $($osInfo.Caption)" -ForegroundColor Gray
        Write-Host "Version: $($osInfo.Version)" -ForegroundColor Gray
        Write-Host "Build: $($osInfo.BuildNumber)" -ForegroundColor Gray

        # Hardware Information
        Write-Host "`n[Hardware Information]" -ForegroundColor Green
        $cpu = Get-WmiObject -Class Win32_Processor | Select-Object -First 1
        Write-Host "Processor: $($cpu.Name)" -ForegroundColor Gray
        $ram = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
        Write-Host "RAM: $ram GB" -ForegroundColor Gray

        # Network Information
        Write-Host "`n[Network Information for RDP]" -ForegroundColor Green
        Get-ServerIP -ShowDetails -IPv4Only

        # RDP Service Status
        Write-Host "`n[RDP Service Status]" -ForegroundColor Green
        $rdpService = Get-Service -Name "TermService" -ErrorAction SilentlyContinue
        if ($rdpService) {
            Write-Host "RDP Service (TermService): $($rdpService.Status)" -ForegroundColor $(if ($rdpService.Status -eq "Running") { "Green" } else { "Red" })
        }

        Write-Host "`n" + "=" * 80
    }
    catch {
        Write-Host "Error retrieving server information: $_" -ForegroundColor Red
    }
}

# Execute the main function
Get-ServerIP -ShowDetails
