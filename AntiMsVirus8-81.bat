@echo off
:: AntiMsVirus8-81.bat – detect 8/8.1, then run main_script.ps1
title AntiMsVirus8-81
chcp 65001 >nul

:: ---------- OS guard ----------
for /f "tokens=4-5 delims=. " %%A in ('ver') do (
    set "MAJOR=%%A"
    set "MINOR=%%B"
)
if not "%MAJOR%"=="6" (
    echo ERROR: Tool is Windows 8/8.1 only.
    timeout /t 3 >nul
    exit /b 1
)
if "%MINOR%"=="2"  set "OSSTR=WIN8"
if "%MINOR%"=="3"  set "OSSTR=WIN81"
if not defined OSSTR (
    echo ERROR: Tool is Windows 8/8.1 only.
    timeout /t 3 >nul
    exit /b 1
)

:: ---------- admin guard ----------
net session >nul 2>&1 || (
    echo ERROR: Administrator rights required.
    timeout /t 3 >nul
    exit /b 1
)

:: ---------- locate PowerShell ----------
set "PSCMD="
:: First try PowerShell Core 6.x (pwsh.exe)
for %%P in (pwsh.exe) do if not "%%~$PATH:P"=="" set "PSCMD=%%~$PATH:P"
:: If not found, try Windows PowerShell 5.x (powershell.exe)
if "%PSCMD%"=="" (
    for %%P in (powershell.exe) do if not "%%~$PATH:P"=="" set "PSCMD=%%~$PATH:P"
)
if "%PSCMD%"=="" (
    echo ERROR: PowerShell not found.
    timeout /t 3 >nul
    exit /b 1
)

:: ---------- launch ----------
"%PSCMD%" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0main_script.ps1" -OS %OSSTR%
pause