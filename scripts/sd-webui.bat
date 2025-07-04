@echo off
setlocal enabledelayedexpansion

REM FUNCTION TO DEPLOY SD WEBUI
REM INPUTS
REM %1: ARGUMENT [run|stop|debug]
REM %2: WORKSPACE DIRECTORY (optional, default: %USERPROFILE%\Documents\sd-webui)



REM INITIAL STATEMENTS
REM >>>----------------------------------------------------

REM SET THE BASE DIRECTORY
set "BASE_DIR=%~dp0"
REM Remove trailing backslash
set "BASE_DIR=%BASE_DIR:~0,-1%"
for %%i in ("%BASE_DIR%") do set "REPO_DIR=%%~dpi"
REM Remove trailing backslash
set "REPO_DIR=%REPO_DIR:~0,-1%"

REM SOURCE THE ENVIRONMENT
for /f "tokens=1,2 delims==" %%a in ('type "%REPO_DIR%\run.env" ^| findstr /v "^#" ^| findstr /v "^$"') do (
    set "%%a=%%b"
)

REM <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



REM CHECK IF ANY INPUT ARGUMENTS ARE PROVIDED
REM >>>----------------------------------------------------

if "%~1"=="" goto :usage
if not "%~3"=="" goto :usage

set "COMMAND=%~1"
if /i not "%COMMAND%"=="run" if /i not "%COMMAND%"=="start" if /i not "%COMMAND%"=="down" if /i not "%COMMAND%"=="stop" if /i not "%COMMAND%"=="debug" (
    call :EchoRed "[%~nx0] INVALID INPUT. PLEASE USE \"run\", \"stop\", OR \"debug\"."
    exit /b 1
)

REM CHECK IF INPUT STATEMENT %2 IS PROVIDED
if not "%~2"=="" (
    set "WORKSPACE_DIR=%~2"
    call :CheckDir "!WORKSPACE_DIR!"
) else (
    set "WORKSPACE_DIR=%USERPROFILE%\Documents\sd-webui"
    call :CheckDir "!WORKSPACE_DIR!" create
)

REM <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



REM MAIN STATEMENTS
REM >>>----------------------------------------------------

if /i "%COMMAND%"=="run" (
    REM RUN THE SD-WEBUI CONTAINER    
    call :EchoYellow "[%~nx0] RUNNING SD-WEBUI CONTAINER"
    call :EchoYellow "[%~nx0] WORKSPACE DIRECTORY: !WORKSPACE_DIR!"

    copy "%REPO_DIR%\compose.yml" "!WORKSPACE_DIR!\compose.yml" >nul
    copy "%REPO_DIR%\run.env" "!WORKSPACE_DIR!\run.env" >nul

    REM Replace variables in run.env
    powershell -Command "(Get-Content '!WORKSPACE_DIR!\run.env') -replace '\$\{WORKSPACE_DIR\}', '!WORKSPACE_DIR!' | Set-Content '!WORKSPACE_DIR!\run.env'"
    powershell -Command "(Get-Content '!WORKSPACE_DIR!\run.env') -replace '\$\{ENTRYPOINT\}', '/usr/local/bin/entrypoint.sh' | Set-Content '!WORKSPACE_DIR!\run.env'"
    
    REM Get current user ID (Windows doesn't have direct equivalent, using 1000 as default)
    powershell -Command "(Get-Content '!WORKSPACE_DIR!\run.env') -replace '\$\{PUID\}', '1000' | Set-Content '!WORKSPACE_DIR!\run.env'"
    powershell -Command "(Get-Content '!WORKSPACE_DIR!\run.env') -replace '\$\{PGID\}', '1000' | Set-Content '!WORKSPACE_DIR!\run.env'"

    REM CHECK IF stable-diffusion-webui DIRECTORY EXISTS IN WORKSPACE DIRECTORY
    if not exist "!WORKSPACE_DIR!\stable-diffusion-webui" (
        call :EchoYellow "[%~nx0] DIRECTORY stable-diffusion-webui NOT FOUND IN WORKSPACE DIRECTORY"
        call :EchoYellow "[%~nx0] CLONING STABLE-DIFFUSION-WEBUI REPOSITORY"
        git clone ^
            https://github.com/AUTOMATIC1111/stable-diffusion-webui.git ^
            "!WORKSPACE_DIR!\stable-diffusion-webui" ^
            -b !WEBUI_VERSION!
    ) else (
        call :EchoGreen "[%~nx0] DIRECTORY stable-diffusion-webui EXISTS IN WORKSPACE DIRECTORY"
    )

    docker compose ^
        -f "!WORKSPACE_DIR!\compose.yml" ^
        --env-file "!WORKSPACE_DIR!\run.env" ^
        up -d

    call :EchoGreen "[%~nx0] SD-WEBUI CONTAINER RUNNING SUCCESSFULLY"
    call :EchoBoxLine

) else if /i "%COMMAND%"=="start" (
    REM START THE SD-WEBUI CONTAINER

    REM CHECK IF compose.yml EXISTS IN WORKSPACE DIRECTORY
    if exist "!WORKSPACE_DIR!\compose.yml" if exist "!WORKSPACE_DIR!\run.env" (
        call :EchoYellow "[%~nx0] STARTING SD-WEBUI CONTAINER"

        docker compose ^
            -f "!WORKSPACE_DIR!\compose.yml" ^
            --env-file "!WORKSPACE_DIR!\run.env" ^
            start

        call :EchoGreen "[%~nx0] SD-WEBUI CONTAINER STARTED SUCCESSFULLY"

        call :EchoBoxLine
    ) else (
        call :EchoRed "[%~nx0] compose.yml OR run.env NOT FOUND IN WORKSPACE DIRECTORY"
        call :EchoRed "[%~nx0] PLEASE RUN THE SD-WEBUI CONTAINER FIRST"
        call :EchoRed "[%~nx0] IF YOU DID, PLEASE CHECK IF compose.yml EXISTS IN !WORKSPACE_DIR!"

        call :EchoBoxLine
        exit /b 1
    )

) else if /i "%COMMAND%"=="down" (
    REM STOP THE SD-WEBUI CONTAINER

    REM CHECK IF compose.yml EXISTS IN WORKSPACE DIRECTORY
    if exist "!WORKSPACE_DIR!\compose.yml" if exist "!WORKSPACE_DIR!\run.env" (
        call :EchoYellow "[%~nx0] STOPPING SD-WEBUI CONTAINER"

        docker compose ^
            -f "!WORKSPACE_DIR!\compose.yml" ^
            --env-file "!WORKSPACE_DIR!\run.env" ^
            down

        call :EchoGreen "[%~nx0] SD-WEBUI CONTAINER DOWN SUCCESSFULLY"

        call :EchoBoxLine
    ) else (
        call :EchoRed "[%~nx0] compose.yml OR run.env NOT FOUND IN WORKSPACE DIRECTORY"
        call :EchoRed "[%~nx0] PLEASE RUN THE SD-WEBUI CONTAINER FIRST"
        call :EchoRed "[%~nx0] IF YOU DID, PLEASE CHECK IF compose.yml EXISTS IN !WORKSPACE_DIR!"

        call :EchoBoxLine
        exit /b 1
    )

) else if /i "%COMMAND%"=="stop" (
    REM STOP THE SD-WEBUI CONTAINER

    REM CHECK IF compose.yml EXISTS IN WORKSPACE DIRECTORY
    if exist "!WORKSPACE_DIR!\compose.yml" if exist "!WORKSPACE_DIR!\run.env" (
        call :EchoYellow "[%~nx0] STOPPING SD-WEBUI CONTAINER"

        docker compose ^
            -f "!WORKSPACE_DIR!\compose.yml" ^
            --env-file "!WORKSPACE_DIR!\run.env" ^
            stop

        call :EchoGreen "[%~nx0] SD-WEBUI CONTAINER STOPPED SUCCESSFULLY"

        call :EchoBoxLine
    ) else (
        call :EchoRed "[%~nx0] compose.yml OR run.env NOT FOUND IN WORKSPACE DIRECTORY"
        call :EchoRed "[%~nx0] PLEASE RUN THE SD-WEBUI CONTAINER FIRST"
        call :EchoRed "[%~nx0] IF YOU DID, PLEASE CHECK IF compose.yml EXISTS IN !WORKSPACE_DIR!"

        call :EchoBoxLine
        exit /b 1
    )

) else if /i "%COMMAND%"=="debug" (
    REM RUN THE SD-WEBUI CONTAINER IN DEBUG MODE
    call :EchoYellow "[%~nx0] RUNNING SD-WEBUI CONTAINER IN DEBUG MODE"
    call :EchoYellow "[%~nx0] WORKSPACE DIRECTORY: !WORKSPACE_DIR!"

    copy "%REPO_DIR%\compose.yml" "!WORKSPACE_DIR!\compose.yml" >nul
    copy "%REPO_DIR%\run.env" "!WORKSPACE_DIR!\run.env" >nul

    REM Replace variables in run.env
    powershell -Command "(Get-Content '!WORKSPACE_DIR!\run.env') -replace '\$\{WORKSPACE_DIR\}', '!WORKSPACE_DIR!' | Set-Content '!WORKSPACE_DIR!\run.env'"
    powershell -Command "(Get-Content '!WORKSPACE_DIR!\run.env') -replace '\$\{ENTRYPOINT\}', '''bash -c \"sleep infinity\"''' | Set-Content '!WORKSPACE_DIR!\run.env'"
    
    REM Get current user ID (Windows doesn't have direct equivalent, using 1000 as default)
    powershell -Command "(Get-Content '!WORKSPACE_DIR!\run.env') -replace '\$\{PUID\}', '1000' | Set-Content '!WORKSPACE_DIR!\run.env'"
    powershell -Command "(Get-Content '!WORKSPACE_DIR!\run.env') -replace '\$\{PGID\}', '1000' | Set-Content '!WORKSPACE_DIR!\run.env'"

    REM CHECK IF stable-diffusion-webui DIRECTORY EXISTS IN WORKSPACE DIRECTORY
    if not exist "!WORKSPACE_DIR!\stable-diffusion-webui" (
        call :EchoYellow "[%~nx0] DIRECTORY stable-diffusion-webui NOT FOUND IN WORKSPACE DIRECTORY"
        call :EchoYellow "[%~nx0] CLONING STABLE-DIFFUSION-WEBUI REPOSITORY"
        git clone ^
            https://github.com/AUTOMATIC1111/stable-diffusion-webui.git ^
            "!WORKSPACE_DIR!\stable-diffusion-webui" ^
            -b !WEBUI_VERSION!
    ) else (
        call :EchoGreen "[%~nx0] DIRECTORY stable-diffusion-webui EXISTS IN WORKSPACE DIRECTORY"
    )

    docker compose ^
        -f "!WORKSPACE_DIR!\compose.yml" ^
        --env-file "!WORKSPACE_DIR!\run.env" ^
        up -d

    call :EchoGreen "[%~nx0] SD-WEBUI CONTAINER RUNNING SUCCESSFULLY"
    call :EchoBoxLine
)

goto :eof

REM <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



REM DEFINE USAGE FUNCTION
REM >>>----------------------------------------------------

:usage
echo Usage: %~nx0 [run^|stop^|debug] [WORKSPACE_DIR (optional)]
echo run: RUN THE SD-WEBUI CONTAINER
echo stop: STOP THE SD-WEBUI CONTAINER
echo debug: RUN THE SD-WEBUI CONTAINER IN DEBUG MODE
exit /b 1

REM <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



REM FUNCTION DEFINITIONS
REM >>>----------------------------------------------------

REM FUNCTION TO ECHO INPUT IN GREEN
:EchoGreen
powershell -Command "Write-Host '%~1' -ForegroundColor Green"
exit /b 0

REM FUNCTION TO ECHO INPUT IN RED
:EchoRed
powershell -Command "Write-Host '%~1' -ForegroundColor Red"
exit /b 0

REM FUNCTION TO ECHO INPUT IN YELLOW
:EchoYellow
powershell -Command "Write-Host '%~1' -ForegroundColor Yellow"
exit /b 0

REM FUNCTION TO PRINT A LINE OF BOXLINES
:EchoBoxLine
for /f "tokens=2" %%a in ('mode con ^| findstr "Columns:"') do set "cols=%%a"
set "line="
for /l %%i in (1,1,%cols%) do set "line=!line!-"
echo %line%
exit /b 0

REM FUNCTION TO CHECK IF A DIRECTORY EXISTS
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

REM <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

endlocal