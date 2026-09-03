#!/bin/bash
# ============================================
#  Maksabi - Prepare Distribution Package
#  Run this on Linux to create Windows package
# ============================================

set -e

echo ""
echo "========================================"
echo "  Maksabi - Distribution Package Builder"
echo "========================================"
echo ""

DIST_DIR="dist"
APP_DIR="$DIST_DIR/app"
BUILD_DIR="build/windows/x64/release/bundle"

# Check if Windows build exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "[ERROR] Windows build not found at: $BUILD_DIR"
    echo ""
    echo "Please build for Windows first:"
    echo "  1. Copy project to Windows machine"
    echo "  2. Run: build_windows.bat"
    echo ""
    echo "Or if you have the build files elsewhere, copy them to:"
    echo "  $BUILD_DIR"
    exit 1
fi

echo "[1/4] Creating distribution directory..."
rm -rf "$DIST_DIR"
mkdir -p "$APP_DIR"

echo "[2/4] Copying build files..."
cp -r "$BUILD_DIR"/* "$APP_DIR/"

echo "[3/4] Copying installer script..."
cp dist/install.bat "$DIST_DIR/"

echo "[4/4] Creating README..."
cat > "$DIST_DIR/README.txt" << 'EOF'
Maksabi - Profit Tracking System
================================

Installation:
1. Double-click install.bat
2. Follow the prompts
3. Launch from Desktop or Start Menu

Manual Run:
- Open the 'app' folder
- Double-click maksabi.exe

Uninstallation:
- Run uninstall.bat from installation directory
- Or manually delete the installation folder

Requirements:
- Windows 10 or later
- Visual C++ Redistributable (usually pre-installed)

For support, visit: https://github.com/CODE-NAME-IN-B/Maksabi
EOF

echo ""
echo "========================================"
echo "  Distribution package created!"
echo "========================================"
echo ""
echo "Location: $DIST_DIR/"
echo ""
echo "Files:"
ls -la "$DIST_DIR/"
echo ""
echo "To distribute:"
echo "  1. Zip the 'dist' folder"
echo "  2. Share the ZIP file"
echo "  3. Users extract and run install.bat"
echo ""
