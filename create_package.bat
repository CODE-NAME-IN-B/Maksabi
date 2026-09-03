@echo off
REM ============================================
REM  Maksabi - Portable Installer Creator
REM  Creates a self-extracting installer
REM ============================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   Maksabi - Portable Installer Creator
echo ========================================
echo.

REM Check for 7-Zip
set "SEVENZIP="
where 7z >nul 2>nul && set "SEVENZIP=7z"
if "%SEVENZIP%"=="" (
    if exist "C:\Program Files\7-Zip\7z.exe" set "SEVENZIP=C:\Program Files\7-Zip\7z.exe"
    if exist "C:\Program Files (x86)\7-Zip\7z.exe" set "SEVENZIP=C:\Program Files (x86)\7-Zip\7z.exe"
)

if "%SEVENZIP%"=="" (
    echo [INFO] 7-Zip not found. Creating simple package instead.
    goto :simple_package
)

REM Check for Windows build
if not exist "build\windows\x64\runner\Release\maksabi.exe" (
    echo [ERROR] Windows build not found.
    echo Please run build_windows.bat first.
    pause
    exit /b 1
)

echo [1/3] Creating portable package...
if not exist "build\package" mkdir "build\package"
xcopy /E /I /Y "build\windows\x64\runner\Release\*" "build\package\app\" >nul

REM Copy VC++ Redistributable if available
if exist "installer\vc_redist.x64.exe" (
    copy "installer\vc_redist.x64.exe" "build\package\" >nul
)

REM Create install script in package
(
    echo @echo off
    echo echo Installing Maksabi...
    echo set "INSTALL_DIR=%%LOCALAPPDATA%%\Maksabi"
    echo if not exist "%%INSTALL_DIR%%" mkdir "%%INSTALL_DIR%%"
    echo xcopy /E /I /Y "app\*" "%%INSTALL_DIR%%\" ^>nul
    echo echo Creating shortcut...
    echo powershell -Command "$ws = New-Object -ComObject WScript.Shell; $sc = $ws.CreateShortcut('%%USERPROFILE%%\Desktop\Maksabi.lnk'); $sc.TargetPath = '%%INSTALL_DIR%%\maksabi.exe'; $sc.WorkingDirectory = '%%INSTALL_DIR%%'; $sc.Save()"
    echo echo Done! Maksabi installed to: %%INSTALL_DIR%%
    echo pause
) > "build\package\install.bat"

echo [2/3] Creating ZIP archive...
"%SEVENZIP%" a -tzip "build\maksabi-portable.zip" "build\package\*" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Failed to create ZIP.
    pause
    exit /b 1
)

echo [3/3] Package created!
echo.
echo ========================================
echo   Package Ready!
echo ========================================
echo.
echo ZIP Location: build\maksabi-portable.zip
echo.
echo To distribute:
echo   1. Share the ZIP file
echo   2. Users extract and run install.bat
echo.
goto :end

:simple_package
echo.
echo Creating simple package structure...
if not exist "build\package" mkdir "build\package"

if exist "build\windows\x64\runner\Release\maksabi.exe" (
    xcopy /E /I /Y "build\windows\x64\runner\Release\*" "build\package\app\" >nul
    
    REM Create install script
    (
        echo @echo off
        echo echo Installing Maksabi...
        echo set "INSTALL_DIR=%%LOCALAPPDATA%%\Maksabi"
        echo if not exist "%%INSTALL_DIR%%" mkdir "%%INSTALL_DIR%%"
        echo xcopy /E /I /Y "app\*" "%%INSTALL_DIR%%\" ^>nul
        echo echo Creating shortcut...
        echo powershell -Command "$ws = New-Object -ComObject WScript.Shell; $sc = $ws.CreateShortcut('%%USERPROFILE%%\Desktop\Maksabi.lnk'); $sc.TargetPath = '%%INSTALL_DIR%%\maksabi.exe'; $sc.WorkingDirectory = '%%INSTALL_DIR%%'; $sc.Save()"
        echo echo Done! Maksabi installed to: %%INSTALL_DIR%%
        echo pause
    ) > "build\package\install.bat"
    
    echo.
    echo Package created at: build\package\
    echo.
    echo To create ZIP manually:
    echo   1. Right-click build\package folder
    echo   2. Select Send to ^> Compressed folder
    echo   3. Share the ZIP file
) else (
    echo.
    echo [ERROR] Windows build not found.
    echo Please run build_windows.bat first.
)

:end
pause
