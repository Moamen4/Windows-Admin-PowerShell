# Get Printer Information - Name and Port
# This script retrieves all printers installed on the system with their names and ports

<#
.SYNOPSIS
    Retrieves detailed printer information including printer names and their ports

.DESCRIPTION
    Lists all printers on the local machine with details such as:
    - Printer Name
    - Port Name
    - Driver Name
    - Status
    - Shared Status
    - Location

.EXAMPLE
    . .\Get-PrinterInfo.ps1
    Get-PrinterInfo

.NOTES
    Requires: Administrator privileges
    Author: Windows Admin Toolkit
    Date: 2026-05-12
#>

function Get-PrinterInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$PrinterName
    )

    try {
        Write-Host "=" * 80
        Write-Host "Printer Information - Local System" -ForegroundColor Cyan
        Write-Host "=" * 80

        if ($PrinterName) {
            # Get specific printer
            $printers = Get-Printer -Name $PrinterName -ErrorAction Stop
        } else {
            # Get all printers
            $printers = Get-Printer -ErrorAction Stop
        }

        if ($printers.Count -eq 0 -and -not $PrinterName) {
            Write-Host "No printers found on this system." -ForegroundColor Yellow
            return
        }

        foreach ($printer in $printers) {
            Write-Host "`nPrinter Name: $($printer.Name)" -ForegroundColor Green
            Write-Host "Status: $($printer.PrinterStatus)" -ForegroundColor Gray
            Write-Host "Location: $($printer.Location)" -ForegroundColor Gray
            Write-Host "Shared: $($printer.Shared)" -ForegroundColor Gray
            Write-Host "Share Name: $($printer.ShareName)" -ForegroundColor Gray
            
            # Get port information
            $portInfo = Get-PrinterPort -PrinterName $printer.Name -ErrorAction SilentlyContinue
            if ($portInfo) {
                Write-Host "Port Name: $($portInfo.Name)" -ForegroundColor Yellow
                Write-Host "Port Type: $($portInfo.PortMonitorName)" -ForegroundColor Yellow
                Write-Host "Port Address: $($portInfo.PrinterHostAddress)" -ForegroundColor Yellow
            }
        }

        Write-Host "`n" + "=" * 80
        Write-Host "Total Printers Found: $($printers.Count)" -ForegroundColor Cyan
        Write-Host "=" * 80
    }
    catch {
        Write-Host "Error retrieving printer information: $_" -ForegroundColor Red
        Write-Host "Please ensure you are running as Administrator." -ForegroundColor Yellow
    }
}

# Alternative method using WMI (works on older PowerShell versions)
function Get-PrinterInfo-WMI {
    [CmdletBinding()]
    param()

    try {
        Write-Host "=" * 80
        Write-Host "Printer Information (WMI Method) - Local System" -ForegroundColor Cyan
        Write-Host "=" * 80

        $printers = Get-WmiObject -Class Win32_Printer

        if (-not $printers) {
            Write-Host "No printers found." -ForegroundColor Yellow
            return
        }

        foreach ($printer in $printers) {
            Write-Host "`nPrinter Name: $($printer.Name)" -ForegroundColor Green
            Write-Host "Port Name: $($printer.PortName)" -ForegroundColor Yellow
            Write-Host "Driver Name: $($printer.DriverName)" -ForegroundColor Gray
            Write-Host "Status: $(if ($printer.PrinterStatus -eq 3) { 'Idle' } elseif ($printer.PrinterStatus -eq 4) { 'Printing' } else { 'Other' })" -ForegroundColor Gray
            Write-Host "Shared: $($printer.Shared)" -ForegroundColor Gray
            Write-Host "Share Name: $($printer.ShareName)" -ForegroundColor Gray
            Write-Host "Print Processor: $($printer.PrintProcessor)" -ForegroundColor Gray
        }

        Write-Host "`n" + "=" * 80
        Write-Host "Total Printers Found: $($printers.Count)" -ForegroundColor Cyan
        Write-Host "=" * 80
    }
    catch {
        Write-Host "Error retrieving printer information: $_" -ForegroundColor Red
    }
}

# Execute the function
Get-PrinterInfo
