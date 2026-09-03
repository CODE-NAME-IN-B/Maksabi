#!/bin/bash
# ============================================
#  Maksabi - Run on Linux
#  شغّل التطبيق على لينكس
# ============================================

echo ""
echo "========================================"
echo "  مكسبي - نظام تتبع الأرباح"
echo "  Maksabi - Profit Tracking System"
echo "========================================"
echo ""

APP_DIR="$(dirname "$0")/build/linux/x64/release/bundle"
APP_EXE="$APP_DIR/maksabi"

# Check if app exists
if [ ! -f "$APP_EXE" ]; then
    echo "[ERROR] App not found at: $APP_EXE"
    echo ""
    echo "Please build first:"
    echo "  flutter build linux --release"
    exit 1
fi

echo "Starting Maksabi..."
echo "App location: $APP_DIR"
echo ""

# Run the app
cd "$APP_DIR"
./maksabi "$@"
