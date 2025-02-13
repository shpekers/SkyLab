@echo off
chcp 65001 >nul
:: 65001 - UTF-8

set "arg=%1"
if "%arg%" == "admin" (
    goto :restarted
) else (
    powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\" admin\"'" -Verb RunAs
    exit /b
)

:restarted
set SRVCNAME=SkyLab

net stop %SRVCNAME% >nul 2>&1
sc delete %SRVCNAME% >nul 2>&1

net stop "WinDivert" >nul 2>&1
sc delete "WinDivert" >nul 2>&1
net stop "WinDivert14" >nul 2>&1
sc delete "WinDivert14" >nul 2>&1
net stop "SkyService" >nul 2>&1
sc delete "SkyService" >nul 2>&1
net stop "SkyDiscord" >nul 2>&1
sc delete "SkyDiscord" >nul 2>&1
exit