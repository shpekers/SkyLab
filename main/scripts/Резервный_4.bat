@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
:: 65001 - UTF-8

set "arg=%1"
if "%arg%" == "admin" (
    echo Restarted with admin rights
) else (
    powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/k \"\"%~f0\" admin\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
echo:

set BIN_PATH=%~dp0bin\

:: Ищем только v5.bat
set "selectedFile="
if exist "v5.bat" (
    set "selectedFile=v5.bat"
    echo Found: !selectedFile!
) else (
    echo v5.bat not found in the current directory.
    pause
    exit /b
)

:: Parsing args (mergeargs: 2=start param|1=params args|0=default)
set "args="
set "capture=0"
set "mergeargs=0"
set QUOTE="

for /f "tokens=*" %%a in ('type "!selectedFile!"') do (
    set "line=%%a"

    echo !line! | findstr /i "%BIN%SkyService.exe" >nul
    if not errorlevel 1 (
        set "capture=1"
    )

    if !capture!==1 (
        if not defined args (
            set "line=!line:*%BIN%SkyService.exe"=!"
        )

        set "temp_args="
        for %%i in (!line!) do (
            set "arg=%%i"

            if not "!arg!"=="^" (
                if "!arg:~0,2!" EQU "--" if not !mergeargs!==0 (
                    set "mergeargs=0"
                )

                if "!arg:~0,1!" EQU "!QUOTE!" (
                    set "arg=!arg:~1,-1!"

                    echo !arg! | findstr ":" >nul
                    if !errorlevel!==0 (
                        set "arg=\!QUOTE!!arg!\!QUOTE!"
                    ) else if "!arg:~0,1!"=="@" (
                        set "arg=\!QUOTE!@%~dp0!arg:~1!\!QUOTE!"
                    ) else if "!arg:~0,5!"=="%%BIN%%" (
                        set "arg=\!QUOTE!!BIN_PATH!!arg:~5!\!QUOTE!"
                    ) else (
                        set "arg=\!QUOTE!%~dp0!arg!\!QUOTE!"
                    )
                )
                
                if !mergeargs!==1 (
                    set "temp_args=!temp_args!,!arg!"
                ) else (
                    set "temp_args=!temp_args! !arg!"
                )

                if "!arg:~0,2!" EQU "--" (
                    set "mergeargs=2"
                ) else if !mergeargs!==2 (
                    set "mergeargs=1"
                )
            )
        )

        if not "!temp_args!"=="" (
            set "args=!args! !temp_args!"
        )
    )
)

:: Creating service with parsed args
set ARGS=%args%
echo Final args: !ARGS!

set SRVCNAME=SkyLab

:: Проверка существования службы
sc query %SRVCNAME% >nul 2>&1
if %errorlevel% NEQ 0 (
    echo Service %SRVCNAME% does not exist, skipping stop and delete.
) else (
    net stop %SRVCNAME%
    sc delete %SRVCNAME%
)

sc create %SRVCNAME% binPath= "\"%BIN_PATH%SkyService.exe\" %ARGS%" DisplayName= "%SRVCNAME%" start= auto
sc description %SRVCNAME% "SkyLab → vavilbisk.ct.ws"
sc start %SRVCNAME%
exit