@echo off
CLS
ECHO.
ECHO =============================
ECHO winget-turbo
ECHO =============================

goto init

:init
setlocal DisableDelayedExpansion
set cmdInvoke=1
set winSysFolder=System32
set "batchPath=%~dpnx0"  rem this works also from cmd shell, other than %~0
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO The elevation is achieved by creating a script which re-launches the batch file to obtain privileges. This causes Windows to present the UAC dialog and asks you for the administrator account and password.
ECHO I have tested it with Windows 7, 8, 8.1, 10, 11, and with Windows XP - it works fine for all.

:gotPrivileges
setlocal DisableDelayedExpansion
REM Read each line from the packages.txt file
for /f %%a in (packages.txt) do (
    set "line=%%a"
    REM Check if the line is blank
    if "!line!" neq "" (
        REM Check if the line starts with a special character '#'
        if "!line:~0,1!" neq "#" (
            REM Start a new cmd instance for each non-comment package
            start "" cmd /c "winget install --id=%%a -e"
        )
    )
)
setlocal EnableDelayedExpansion