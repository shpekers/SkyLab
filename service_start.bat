@echo off
chcp 65001 >nul
:: 65001 - UTF-8

:: Admin rights check

set "arg=%1"
if "%arg%" == "admin" (
    goto :restarted
) else (
    powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/k \"\"%~f0\" admin\"' -Verb RunAs"
    exit /b
)
:restarted
set SRVCNAME=SkyLab

net start %SRVCNAME% >nul 2>&1
exit

