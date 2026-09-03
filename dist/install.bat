@echo off
REM ============================================
REM  Maksabi - Windows Installer Script
REM  Run this on Windows to install the app
REM ============================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   Maksabi - Windows Installer
echo ========================================
echo.

REM Set installation directory
set "INSTALL_DIR=%LOCALAPPDATA%\Maksabi"
set "SHORTCUT_DIR=%USERPROFILE%\Desktop"

echo Installing Maksabi to: %INSTALL_DIR%
echo.

REM Create installation directory
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
    echo Created installation directory.
)

REM Copy files
echo Copying application files...
xcopy /E /I /Y "app\*" "%INSTALL_DIR%\" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Failed to copy files.
    pause
    exit /b 1
)

echo Files copied successfully.

REM Create desktop shortcut
echo Creating desktop shortcut...
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $sc = $ws.CreateShortcut('%SHORTCUT_DIR%\Maksabi.lnk'); $sc.TargetPath = '%INSTALL_DIR%\maksabi.exe'; $sc.WorkingDirectory = '%INSTALL_DIR%'; $sc.Description = 'Maksabi - Profit Tracking System'; $sc.Save()"

if exist "%SHORTCUT_DIR%\Maksabi.lnk" (
    echo Desktop shortcut created.
) else (
    echo [WARNING] Could not create desktop shortcut.
)

REM Create Start Menu shortcut
echo Creating Start Menu shortcut...
set "START_MENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs"
if not exist "%START_MENU%\Maksabi" mkdir "%START_MENU%\Maksabi"
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $sc = $ws.CreateShortcut('%START_MENU%\Maksabi\Maksabi.lnk'); $sc.TargetPath = '%INSTALL_DIR%\maksabi.exe'; $sc.WorkingDirectory = '%INSTALL_DIR%'; $sc.Description = 'Maksabi - Profit Tracking System'; $sc.Save()"

if exist "%START_MENU%\Maksabi\Maksabi.lnk" (
    echo Start Menu shortcut created.
) else (
    echo [WARNING] Could not create Start Menu shortcut.
)

REM Create uninstaller
echo Creating uninstaller...
(
    echo @echo off
    echo echo Uninstalling Maksabi...
    echo rmdir /S /Q "%INSTALL_DIR%"
    echo del "%SHORTCUT_DIR%\Maksabi.lnk" 2^>nul
    echo rmdir /S /Q "%START_MENU%\Maksabi" 2^>nul
    echo echo Maksabi has been uninstalled.
    echo pause
) > "%INSTALL_DIR%\uninstall.bat"

echo Uninstaller created.

echo.
echo ========================================
echo   Installation Complete!
echo ========================================
echo.
echo Maksabi has been installed to:
echo   %INSTALL_DIR%
echo.
echo You can now:
echo   - Launch from Desktop shortcut
echo   - Launch from Start Menu
echo   - Uninstall using uninstall.bat
echo.

REM Ask to launch
set /p "LAUNCH=Do you want to launch Maksabi now? (Y/N): "
if /i "%LAUNCH%"=="Y" (
    echo Launching Maksabi...
    start "" "%INSTALL_DIR%\maksabi.exe"
)

pause
