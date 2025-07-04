@echo off

REM FUNCTION DEFINITIONS FOR OTHER RUN SCRIPTS

REM FUNCTION TO ECHO INPUT IN GREEN
REM >>>-------------------------------------------------------------
REM INPUTS:
REM %~1: INPUT TO ECHO
REM ----------------------------------------------------------------
:EchoGreen
powershell -Command "Write-Host '%~1' -ForegroundColor Green"
exit /b 0
REM <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


REM FUNCTION TO ECHO INPUT IN RED
REM >>>-------------------------------------------------------------
REM INPUTS:
REM %~1: INPUT TO ECHO
REM ----------------------------------------------------------------
:EchoRed
powershell -Command "Write-Host '%~1' -ForegroundColor Red"
exit /b 0
REM <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


REM FUNCTION TO ECHO INPUT IN YELLOW
REM >>>-------------------------------------------------------------
REM INPUTS:
REM %~1: INPUT TO ECHO
REM ----------------------------------------------------------------
:EchoYellow
powershell -Command "Write-Host '%~1' -ForegroundColor Yellow"
exit /b 0
REM <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


REM FUNCTION TO PRINT A LINE OF BOXLINES
REM >>>-------------------------------------------------------------
:EchoBoxLine
for /f "tokens=2" %%a in ('mode con ^| findstr "Columns:"') do set "cols=%%a"
set "line="
for /l %%i in (1,1,%cols%) do set "line=!line!-"
echo %line%
exit /b 0
REM <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


REM FUNCTION TO CHECK IF A DIRECTORY EXISTS
REM >>>-------------------------------------------------------------
REM INPUTS:
REM %~1: DIRECTORY TO CHECK
REM %~2=create: CREATE DIRECTORY IF IT DOES NOT EXIST (optional)
REM ----------------------------------------------------------------
:CheckDir
setlocal enabledelayedexpansion

REM Check argument count
if "%~1"=="" (
    call :EchoRed "[CheckDir] INSUFFICIENT NUMBER OF ARGUMENTS"
    exit /b 1
)

if not "%~3"=="" (
    call :EchoRed "[CheckDir] TOO MANY ARGUMENTS"
    exit /b 1
)

set "DIR_PATH=%~1"
set "CREATE_FLAG=%~2"

if exist "%DIR_PATH%\" (
    call :EchoGreen "[CheckDir] DIRECTORY %DIR_PATH% EXISTS"
    if /i "%CREATE_FLAG%"=="create" (
        call :EchoYellow "[CheckDir] THE SECOND ARGUMENT WILL BE IGNORED"
    )
) else (
    call :EchoRed "[CheckDir] DIRECTORY %DIR_PATH% DOES NOT EXIST"
    if /i "%CREATE_FLAG%"=="create" (
        call :EchoYellow "[CheckDir] CREATING DIRECTORY %DIR_PATH%"
        mkdir "%DIR_PATH%"
    ) else (
        call :EchoRed "[CheckDir] PLEASE CREATE DIRECTORY %DIR_PATH%"
        exit /b 1
    )
)

endlocal
exit /b 0
REM <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<