# Building Maksabi for Windows

## Prerequisites

1. **Flutter SDK** - Install from https://docs.flutter.dev/get-started/install/windows
2. **Visual Studio 2022+** - With "Desktop development with C++" workload
   - Download from https://visualstudio.microsoft.com/
3. **Inno Setup** (optional) - For creating installer
   - Download from https://jrsoftware.org/isdl.php

## Quick Build

### Option 1: Using Build Script (Recommended)

1. Copy this project to your Windows machine
2. Open Command Prompt in the project directory
3. Run:
   ```batch
   build_windows.bat
   ```

### Option 2: Manual Build

1. Open Command Prompt in the project directory

2. Enable Windows platform:
   ```batch
   flutter create --platforms=windows .
   ```

3. Get dependencies:
   ```batch
   flutter pub get
   ```

4. Run code generation:
   ```batch
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. Build release:
   ```batch
   flutter build windows --release
   ```

6. Find the executable:
   ```
   build\windows\x64\runner\Release\maksabi.exe
   ```

## Creating Installer

### Using Inno Setup

1. Install Inno Setup from https://jrsoftware.org/isdl.php
2. Open `installer\maksabi.iss` in Inno Setup
3. Click **Build > Compile**
4. Installer will be created in `build\installer\`

### Creating Portable ZIP

1. Copy the entire `build\windows\x64\runner\Release\` folder
2. Zip it with the VC++ Redistributable files:
   - `msvcp140.dll`
   - `vcruntime140.dll`
   - `vcruntime140_1.dll`
3. Users can extract and run `maksabi.exe` directly

## Distribution

### Option 1: Installer (Recommended)
- Use the Inno Setup installer for professional distribution
- Includes shortcuts, uninstaller, and VC++ Redistributable

### Option 2: Portable ZIP
- Share the zipped Release folder
- Users extract and run directly
- May require VC++ Redistributable to be installed separately

### Option 3: MSIX Package
- For Microsoft Store distribution
- Run: `flutter build windows --release`
- Use MSIX Packaging Tool

## Troubleshooting

### "Flutter is not recognized"
- Ensure Flutter is in your PATH
- Run `flutter doctor` to check installation

### "Visual Studio not found"
- Install Visual Studio 2022+ with C++ workload
- Run `flutter doctor` to verify

### Missing VC++ Redistributable
- Download from: https://aka.ms/vs/17/release/vc_redist.x64.exe
- Install on target machine

### Build fails with "CMake not found"
- Visual Studio should include CMake
- Or install CMake separately: https://cmake.org/download/

## File Structure

```
build\windows\x64\runner\Release\
├── maksabi.exe          # Main executable
├── flutter_windows.dll  # Flutter engine
├── *.dll               # Required DLLs
└── data\
    ├── flutter_assets  # App assets
    ├── icudtl.dat      # ICU data
    └── ...
```
