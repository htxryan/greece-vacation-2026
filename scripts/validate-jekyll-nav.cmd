@echo off
REM Cross-platform wrapper for Jekyll navigation validation (Windows)

setlocal enabledelayedexpansion

REM Get script directory and project root
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%\..") do set "PROJECT_ROOT=%%~fI"

ruby "%SCRIPT_DIR%\validate-jekyll-nav.rb" "%PROJECT_ROOT%"
