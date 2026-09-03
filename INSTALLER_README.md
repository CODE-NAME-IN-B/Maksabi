# Maksabi - Windows Installer Package

## Quick Start (5 minutes)

### Step 1: Copy Project to Windows
Copy the entire `Maksabi` folder to your Windows machine.

### Step 2: Build the EXE
Open Command Prompt in the project folder:
```batch
build_windows.bat
```

### Step 3: Create Installer
Run this command:
```batch
create_installer.bat
```

### Step 4: Distribute
Your installer is at:
```
build\installer\maksabi-setup-1.0.0.exe
```

---

## Alternative: Portable Package

If you don't want to install Inno Setup:

### Step 1: Create Package
```batch
create_package.bat
```

### Step 2: Distribute
Share the ZIP file:
```
build\maksabi-portable.zip
```

Users extract and run `install.bat`.

---

## Files Overview

| File | Purpose |
|------|---------|
| `build_windows.bat` | Builds the Windows EXE |
| `create_installer.bat` | Creates Inno Setup installer |
| `create_package.bat` | Creates portable ZIP package |
| `installer/maksabi.iss` | Inno Setup configuration |
| `BUILD_WINDOWS.md` | Detailed instructions |

---

## Requirements

### For Building
- Windows 10 or later
- Flutter SDK
- Visual Studio 2022+ with C++ workload

### For Installer
- Inno Setup (free): https://jrsoftware.org/isdl.php

### For Portable Package
- 7-Zip (optional): https://www.7-zip.org/

---

## Troubleshooting

### "Flutter not found"
- Install Flutter from: https://docs.flutter.dev/get-started/install/windows
- Add to PATH

### "Visual Studio not found"
- Install Visual Studio 2022+
- Select "Desktop development with C++" workload

### "Inno Setup not found"
- Install from: https://jrsoftware.org/isdl.php
- Add to PATH: `C:\Program Files (x86)\Inno Setup 6`

### Build fails
- Run: `flutter doctor`
- Fix any issues reported
- Try: `flutter clean` then `build_windows.bat`

---

## Support

For issues, check:
1. `flutter doctor` output
2. Build logs in `build\windows\`
3. GitHub Issues: https://github.com/CODE-NAME-IN-B/Maksabi/issues
