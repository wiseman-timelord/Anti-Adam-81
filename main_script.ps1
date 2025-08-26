#Requires -Version 6.0
param(
    [ValidateSet('WIN8','WIN81')]
    [string]$OS
)

# ---------- helpers ----------
function Show-Header([string]$Title) {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "    $Title" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
}

function Get-DefenderStatus {
    $svc = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
    $reg = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -ErrorAction SilentlyContinue
    if ($svc.StartType -eq 'Disabled' -and $reg.DisableAntiSpyware -eq 1) { return 'Disabled' }
    if ($svc.StartType -eq 'Automatic' -and -not $reg.DisableAntiSpyware) { return 'Enabled' }
    return 'Inconsistent'
}

function Get-SatanStatus {
    $svcs = @('Netlogon','W32Time','TermService','RemoteRegistry','iphlpsvc','SSDPSRV','fdPHost','FDResPub','WerSvc','DPS','wuauserv')
    $running  = ($svcs | Where-Object { (Get-Service $_ -ErrorAction SilentlyContinue).Status -eq 'Running' }).Count
    $disabled = ($svcs | Where-Object { (Get-Service $_ -ErrorAction SilentlyContinue).StartType -eq 'Disabled' }).Count
    if ($disabled -eq $svcs.Count) { return 'Disabled' }
    if ($running  -eq $svcs.Count) { return 'Enabled' }
    return 'Inconsistent'
}

function Confirm-Action([string]$Text) {
    $ans = Read-Host "$Text (Y/N)"
    return ($ans -match '^y')
}

function Toggle-Defender {
    Show-Header "AntiMsVirus8-81: Defender Toggle"
    $status = Get-DefenderStatus
    Write-Host ""
    Write-Host " 1. Disable Windows Defender"
    Write-Host " 2. Enable  Windows Defender"
    Write-Host " X. Back to Main Menu"
    Write-Host ""
    $sel = (Read-Host "Select 1-2, X").ToUpper()
    switch ($sel) {
        "1" {
            if (Confirm-Action "Disable Windows Defender") {
                # Registry & service
                $reg = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
                if (-not (Test-Path $reg)) { New-Item -Path $reg -Force | Out-Null }
                Set-ItemProperty -Path $reg -Name DisableAntiSpyware -Value 1 -Force
                Set-ItemProperty -Path "$reg\Real-Time Protection" -Name DisableRealtimeMonitoring -Value 1 -Force -ErrorAction SilentlyContinue
                Stop-Service -Name WinDefend -Force -ErrorAction SilentlyContinue
                Set-Service -Name WinDefend -StartupType Disabled -ErrorAction SilentlyContinue
                # Tasks & processes
                Get-ScheduledTask -TaskPath "\Microsoft\Windows\Windows Defender\*" | Disable-ScheduledTask -ErrorAction SilentlyContinue
                Get-Process -Name MsMpEng,MpCmdRun -ErrorAction SilentlyContinue | Stop-Process -Force
                Write-Host "`n[✓] Defender disabled – restart recommended.`n" -ForegroundColor Green
            }
        }
        "2" {
            if (Confirm-Action "Enable Windows Defender") {
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name DisableRealtimeMonitoring -ErrorAction SilentlyContinue
                Set-Service -Name WinDefend -StartupType Automatic -ErrorAction SilentlyContinue
                Start-Service   -Name WinDefend -ErrorAction SilentlyContinue
                Get-ScheduledTask -TaskPath "\Microsoft\Windows\Windows Defender\*" | Enable-ScheduledTask -ErrorAction SilentlyContinue
                Write-Host "`n[✓] Defender enabled – restart recommended.`n" -ForegroundColor Green
            }
        }
        "X" { return }
    }
    pause
}

function Toggle-Satan {
    Show-Header "AntiMsVirus8-81: AD Services Toggle"
    $status = Get-SatanStatus
    Write-Host ""
    Write-Host " 1. Disable AD-related services"
    Write-Host " 2. Enable  AD-related services"
    Write-Host " X. Back to Main Menu"
    Write-Host ""
    $sel = (Read-Host "Select 1-2, X").ToUpper()
    $svcs = @('Netlogon','W32Time','TermService','RemoteRegistry','iphlpsvc','SSDPSRV','fdPHost','FDResPub','WerSvc','DPS','wuauserv')
    switch ($sel) {
        "1" {
            if (Confirm-Action "Disable AD-related services") {
                foreach ($s in $svcs) {
                    Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
                    Set-Service -Name $s -StartupType Disabled -ErrorAction SilentlyContinue
                }
                Write-Host "`n[✓] AD services disabled – restart recommended.`n" -ForegroundColor Green
            }
        }
        "2" {
            if (Confirm-Action "Enable AD-related services") {
                foreach ($s in $svcs) {
                    Set-Service -Name $s -StartupType Manual -ErrorAction SilentlyContinue
                    Start-Service -Name $s -ErrorAction SilentlyContinue
                }
                Write-Host "`n[✓] AD services enabled – restart recommended.`n" -ForegroundColor Green
            }
        }
        "X" { return }
    }
    pause
}

# ---------- main loop ----------
do {
    $defStatus = Get-DefenderStatus
    $satStatus = Get-SatanStatus
    Show-Header "AntiMsVirus8-81: Main Menu"
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "    1. Active Directory ($satStatus)"
    Write-Host ""
    Write-Host "    2. Windows Defender ($defStatus)"
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "==============================================================================="
    $sel = (Read-Host "Selection; Menu Option = 1-2, Exit Tool = X").ToUpper()
    switch ($sel) {
        "1" { Toggle-Satan  }
        "2" { Toggle-Defender }
        "X" { exit 0 }
    }
} while ($true)