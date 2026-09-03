@echo off
REM ============================================
REM  Maksabi - Full Installer Creator
REM  Run this on Windows to create EXE installer
REM ============================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   Maksabi - Installer Creator
echo ========================================
echo.

REM Check for Inno Setup
where iscc >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Inno Setup not found.
    echo.
    echo Please install Inno Setup from:
    echo https://jrsoftware.org/isdl.php
    echo.
    echo After installation, add to PATH:
    echo   C:\Program Files (x86)\Inno Setup 6
    echo.
    pause
    exit /b 1
)

REM Check for Windows build
if not exist "build\windows\x64\runner\Release\maksabi.exe" (
    echo [ERROR] Windows build not found.
    echo.
    echo Please build first:
    echo   1. Run: build_windows.bat
    echo.
    pause
    exit /b 1
)

echo [1/3] Preparing installer files...
if not exist "build\installer" mkdir "build\installer"

echo [2/3] Compiling installer...
iscc installer\maksabi.iss
if %errorlevel% neq 0 (
    echo [ERROR] Installer compilation failed.
    pause
    exit /b 1
)

echo [3/3] Installer created successfully!
echo.
echo ========================================
echo   Installer Ready!
echo ========================================
echo.
echo Location: build\installer\maksabi-setup-1.0.0.exe
echo.
echo You can now distribute this installer.
echo.

REM Ask to open folder
set /p "OPEN=Open installer folder? (Y/N): "
if /i "%OPEN%"=="Y" (
    explorer build\installer
)

pause
