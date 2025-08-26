#Requires -RunAsAdministrator
param(
    [ValidateSet('WIN8','WIN81')]
    [string]$OS
)

# ---------- helpers ----------
function Show-Header([string]$Title) {
    Clear-Host
    Write-Host ('='*79) -ForegroundColor Cyan
    Write-Host "    $Title" -ForegroundColor Cyan
    Write-Host ('='*79) -ForegroundColor Cyan
}

function Get-DefenderStatus {
    $svc = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
    $reg = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name DisableAntiSpyware -ErrorAction SilentlyContinue
    if ($svc.StartType -eq 'Disabled' -and $reg.DisableAntiSpyware -eq 1) { return 'Disabled' }
    if ($svc.StartType -eq 'Automatic' -and -not $reg.DisableAntiSpyware) { return 'Enabled' }
    return 'Inconsistent'
}

function Get-SatanStatus {
    $svcs = @('Netlogon','W32Time','TermService','RemoteRegistry','iphlpsvc','SSDPSRV','fdPHost','FDResPub','WerSvc','DPS','wuauserv')
    $disabledCount = 0
    $runningCount = 0
    
    foreach ($svc in $svcs) {
        $service = Get-Service $svc -ErrorAction SilentlyContinue
        if ($service) {
            if ($service.StartType -eq 'Disabled') { $disabledCount++ }
            if ($service.Status -eq 'Running') { $runningCount++ }
        }
    }
    
    if ($disabledCount -eq $svcs.Count) { return 'Disabled' }
    if ($runningCount -eq $svcs.Count) { return 'Enabled' }
    return 'Inconsistent'
}

function Enable-Defender {
    Write-Host "Enabling Windows Defender..." -ForegroundColor Green
    Start-Sleep -Seconds 1
    Clear-Host
    Show-Header "Windows Defender - Enable Operation"
    
    Write-Host "Removing registry disable flags..."
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name DisableAntiSpyware -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' -Name DisableRealtimeMonitoring -ErrorAction SilentlyContinue
    
    Write-Host "Setting WinDefend service to Automatic..."
    Set-Service -Name WinDefend -StartupType Automatic -ErrorAction SilentlyContinue
    
    Write-Host "Starting WinDefend service..."
    Start-Service -Name WinDefend -ErrorAction SilentlyContinue
    
    Write-Host "Enabling Windows Defender scheduled tasks..."
    try {
        $tasks = Get-ScheduledTask -TaskPath '\Microsoft\Windows\Windows Defender\*' -ErrorAction Stop
        foreach ($task in $tasks) {
            try {
                Enable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction Stop | Out-Null
                Write-Host "  Enabled: $($task.TaskName)"
            } catch {
                Write-Host "  Failed to enable: $($task.TaskName)"
            }
        }
    } catch {
        Write-Host "  No Windows Defender tasks found or error accessing tasks"
    }
    
    Write-Host ""
    Write-Host ('='*79)
    Write-Host "FINAL STATUS:" -ForegroundColor Yellow
    $finalStatus = Get-DefenderStatus
    if ($finalStatus -eq 'Enabled') {
        Write-Host "Windows Defender: $finalStatus" -ForegroundColor Green
    } else {
        Write-Host "Windows Defender: $finalStatus" -ForegroundColor Red
    }
    Write-Host ('='*79)
    Write-Host "Press any key to return to menu..." -ForegroundColor Cyan
    $null = Read-Host
}

function Disable-Defender {
    Write-Host "Disabling Windows Defender..." -ForegroundColor Red
    Start-Sleep -Seconds 1
    Clear-Host
    Show-Header "Windows Defender - Disable Operation"
    
    Write-Host "Creating registry disable flags..."
    $reg = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'
    if (-not (Test-Path $reg)) { 
        New-Item -Path $reg -Force | Out-Null 
        Write-Host "  Created registry path: $reg"
    }
    Set-ItemProperty -Path $reg -Name DisableAntiSpyware -Value 1 -Force
    Write-Host "  Set DisableAntiSpyware = 1"
    
    if (-not (Test-Path "$reg\Real-Time Protection")) { 
        New-Item -Path "$reg\Real-Time Protection" -Force | Out-Null 
        Write-Host "  Created Real-Time Protection path"
    }
    Set-ItemProperty -Path "$reg\Real-Time Protection" -Name DisableRealtimeMonitoring -Value 1 -Force
    Write-Host "  Set DisableRealtimeMonitoring = 1"
    
    Write-Host "Stopping WinDefend service..."
    Stop-Service -Name WinDefend -Force -ErrorAction SilentlyContinue
    
    Write-Host "Setting WinDefend service to Disabled..."
    Set-Service -Name WinDefend -StartupType Disabled -ErrorAction SilentlyContinue
    
    Write-Host "Disabling Windows Defender scheduled tasks..."
    try {
        $tasks = Get-ScheduledTask -TaskPath '\Microsoft\Windows\Windows Defender\*' -ErrorAction Stop
        foreach ($task in $tasks) {
            try {
                Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction Stop | Out-Null
                Write-Host "  Disabled: $($task.TaskName)"
            } catch {
                Write-Host "  Failed to disable: $($task.TaskName)"
            }
        }
    } catch {
        Write-Host "  No Windows Defender tasks found or error accessing tasks"
    }
    
    Write-Host "Stopping Windows Defender processes..."
    $processes = Get-Process -Name MsMpEng,MpCmdRun -ErrorAction SilentlyContinue
    foreach ($proc in $processes) {
        try {
            Stop-Process -Id $proc.Id -Force -ErrorAction Stop
            Write-Host "  Stopped: $($proc.Name)"
        } catch {
            Write-Host "  Failed to stop: $($proc.Name)"
        }
    }
    
    Write-Host ""
    Write-Host ('='*79)
    Write-Host "FINAL STATUS:" -ForegroundColor Yellow
    $finalStatus = Get-DefenderStatus
    if ($finalStatus -eq 'Disabled') {
        Write-Host "Windows Defender: $finalStatus" -ForegroundColor Green
    } else {
        Write-Host "Windows Defender: $finalStatus" -ForegroundColor Red
    }
    Write-Host ('='*79)
    Write-Host "Press any key to return to menu..." -ForegroundColor Cyan
    $null = Read-Host
}

function Enable-Satan {
    Write-Host "Enabling Active Directory services..." -ForegroundColor Green
    Start-Sleep -Seconds 1
    Clear-Host
    Show-Header "Active Directory - Enable Operation"
    
    $svcs = @('Netlogon','W32Time','TermService','RemoteRegistry','iphlpsvc','SSDPSRV','fdPHost','FDResPub','WerSvc','DPS','wuauserv')
    
    foreach ($s in $svcs) {
        Set-Service -Name $s -StartupType Manual -ErrorAction SilentlyContinue
        try {
            Start-Service -Name $s -ErrorAction Stop
            Write-Host "${s}: Started and set to Manual" -ForegroundColor Green
        } catch {
            Write-Host "${s}: Failed to start" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host ('='*79)
    Write-Host "FINAL STATUS:" -ForegroundColor Yellow
    $finalStatus = Get-SatanStatus
    if ($finalStatus -eq 'Enabled') {
        Write-Host "Active Directory Services: $finalStatus" -ForegroundColor Green
    } else {
        Write-Host "Active Directory Services: $finalStatus" -ForegroundColor Red
    }
    Write-Host ('='*79)
    Write-Host "Press any key to return to menu..." -ForegroundColor Cyan
    $null = Read-Host
}

function Disable-Satan {
    Write-Host "Disabling Active Directory services..." -ForegroundColor Red
    Start-Sleep -Seconds 1
    Clear-Host
    Show-Header "Active Directory - Disable Operation"
    
    $svcs = @('Netlogon','W32Time','TermService','RemoteRegistry','iphlpsvc','SSDPSRV','fdPHost','FDResPub','WerSvc','DPS','wuauserv')
    
    foreach ($s in $svcs) {
        try {
            Stop-Service -Name $s -Force -ErrorAction Stop
            Set-Service -Name $s -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "${s}: Stopped and set to Disabled" -ForegroundColor Green
        } catch {
            Set-Service -Name $s -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "${s}: Set to Disabled (was not running)" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host ('='*79)
    Write-Host "FINAL STATUS:" -ForegroundColor Yellow
    $finalStatus = Get-SatanStatus
    if ($finalStatus -eq 'Disabled') {
        Write-Host "Active Directory Services: $finalStatus" -ForegroundColor Green
    } else {
        Write-Host "Active Directory Services: $finalStatus" -ForegroundColor Red
    }
    Write-Host ('='*79)
    Write-Host "Press any key to return to menu..." -ForegroundColor Cyan
    $null = Read-Host
}

function Toggle-Defender {
    $status = Get-DefenderStatus
    switch ($status) {
        'Disabled' { Enable-Defender }
        'Enabled'  { Disable-Defender }
        'Inconsistent' {
            do {
                $choice = Read-Host "Inconsistent; Do you want to 1) Enable or 2) Disable?"
            } while ($choice -notin @('1','2'))
            
            if ($choice -eq '1') { 
                Enable-Defender 
            } else { 
                Disable-Defender 
            }
        }
    }
}

function Toggle-Satan {
    $status = Get-SatanStatus
    switch ($status) {
        'Disabled' { Enable-Satan }
        'Enabled'  { Disable-Satan }
        'Inconsistent' {
            do {
                $choice = Read-Host "Inconsistent; Do you want to 1) Enable or 2) Disable?"
            } while ($choice -notin @('1','2'))
            
            if ($choice -eq '1') { 
                Enable-Satan 
            } else { 
                Disable-Satan 
            }
        }
    }
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
    Write-Host ('='*79)
    $sel = (Read-Host "Selection; Menu Option = 1-2, Exit Tool = X").ToUpper()
    switch ($sel) {
        "1" { Toggle-Satan  }
        "2" { Toggle-Defender }
        "X" { exit 0 }
    }
} while ($true)