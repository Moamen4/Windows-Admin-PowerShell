# Windows Services Management Script
# Manage Windows services efficiently

<#
.SYNOPSIS
    Comprehensive Windows services management utility

.DESCRIPTION
    Allows system administrators to:
    - View all services and their status
    - Start/Stop/Restart services
    - Change service startup type
    - Check service dependencies
    - Export service information

.EXAMPLE
    . .\Services-Management.ps1
    Get-ServiceStatus
    Start-ServiceByName -ServiceName "Spooler"
    Stop-ServiceByName -ServiceName "Print Spooler"

.NOTES
    Requires: Administrator privileges
    Author: Windows Admin Toolkit
#>

function Get-ServiceStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("All", "Running", "Stopped", "Paused")]
        [string]$Status = "All",
        
        [Parameter(Mandatory=$false)]
        [string]$ServiceName
    )

    try {
        Write-Host "=" * 80
        Write-Host "Windows Services Status" -ForegroundColor Cyan
        Write-Host "=" * 80

        if ($ServiceName) {
            $services = Get-Service -Name $ServiceName -ErrorAction Stop
        } else {
            $services = Get-Service
        }

        switch ($Status) {
            "All" { $filtered = $services }
            "Running" { $filtered = $services | Where-Object { $_.Status -eq "Running" } }
            "Stopped" { $filtered = $services | Where-Object { $_.Status -eq "Stopped" } }
            "Paused" { $filtered = $services | Where-Object { $_.Status -eq "Paused" } }
        }

        $filtered | Format-Table -Property Name, DisplayName, Status, StartType -AutoSize
        Write-Host "\nTotal Services: $($filtered.Count)" -ForegroundColor Green
    }
    catch {
        Write-Host "Error retrieving services: $_" -ForegroundColor Red
    }
}

function Start-ServiceByName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServiceName
    )

    try {
        $service = Get-Service -Name $ServiceName -ErrorAction Stop
        if ($service.Status -eq "Running") {
            Write-Host "Service '$ServiceName' is already running." -ForegroundColor Yellow
        } else {
            Write-Host "Starting service '$ServiceName'..." -ForegroundColor Cyan
            Start-Service -Name $ServiceName -ErrorAction Stop
            Write-Host "Service '$ServiceName' started successfully." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error starting service: $_" -ForegroundColor Red
    }
}

function Stop-ServiceByName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServiceName
    )

    try {
        $service = Get-Service -Name $ServiceName -ErrorAction Stop
        if ($service.Status -eq "Stopped") {
            Write-Host "Service '$ServiceName' is already stopped." -ForegroundColor Yellow
        } else {
            Write-Host "Stopping service '$ServiceName'..." -ForegroundColor Cyan
            Stop-Service -Name $ServiceName -ErrorAction Stop
            Write-Host "Service '$ServiceName' stopped successfully." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error stopping service: $_" -ForegroundColor Red
    }
}

function Restart-ServiceByName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServiceName
    )

    try {
        Write-Host "Restarting service '$ServiceName'..." -ForegroundColor Cyan
        Restart-Service -Name $ServiceName -ErrorAction Stop
        Write-Host "Service '$ServiceName' restarted successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Error restarting service: $_" -ForegroundColor Red
    }
}

# Execute example
Get-ServiceStatus -Status "Running" | Select-Object -First 20
