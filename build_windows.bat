@echo off
REM ============================================
REM  Maksabi Windows Build Script
REM  Run this on Windows with Flutter installed
REM ============================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   Maksabi - Windows Build Script
echo ========================================
echo.

REM Check if Flutter is available
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed or not in PATH.
    echo Please install Flutter from: https://docs.flutter.dev/get-started/install/windows
    pause
    exit /b 1
)

REM Check Flutter version
echo [1/6] Checking Flutter version...
flutter --version
echo.

REM Enable Windows platform (if not already enabled)
echo [2/6] Ensuring Windows platform is enabled...
flutter create --platforms=windows .
echo.

REM Get dependencies
echo [3/6] Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to get dependencies.
    pause
    exit /b 1
)
echo.

REM Run code generation (if needed)
echo [4/6] Running code generation...
flutter pub run build_runner build --delete-conflicting-outputs
echo.

REM Build Windows release
echo [5/6] Building Windows release...
flutter build windows --release
if %errorlevel% neq 0 (
    echo [ERROR] Build failed.
    pause
    exit /b 1
)
echo.

REM Check if Inno Setup is available
echo [6/6] Creating installer...
where iscc >nul 2>nul
if %errorlevel% equ 0 (
    echo Inno Setup found. Creating installer...
    iscc installer\maksabi.iss
    if %errorlevel% equ 0 (
        echo.
        echo ========================================
        echo   BUILD SUCCESSFUL!
        echo ========================================
        echo.
        echo Executable: build\windows\x64\runner\Release\maksabi.exe
        echo Installer:  build\installer\maksabi-setup-1.0.0.exe
        echo.
    ) else (
        echo.
        echo [WARNING] Installer creation failed, but EXE was built successfully.
        echo You can manually create installer using Inno Setup.
        echo.
        echo Executable: build\windows\x64\runner\Release\maksabi.exe
        echo.
    )
) else (
    echo.
    echo Inno Setup not found. Skipping installer creation.
    echo.
    echo To create installer:
    echo 1. Download Inno Setup from: https://jrsoftware.org/isdl.php
    echo 2. Open installer\maksabi.iss in Inno Setup
    echo 3. Click Build ^> Compile
    echo.
    echo Executable location: build\windows\x64\runner\Release\maksabi.exe
    echo.
    echo To create a portable ZIP:
    echo - Copy the entire Release folder
    echo - Include VC++ Redistributable if needed
    echo.
)

echo.
echo ========================================
echo   Build complete!
echo ========================================
echo.
pause
