# مكسبي - Maksabi

**نظام تتبع الأرباح** | Profit Tracking System

A desktop application built with Flutter for tracking business profits, sales, capital, and expenses with a modern dark-themed Arabic UI.

---

## Features

- **Dashboard** — Real-time profit/loss overview with ROI and margin metrics
- **Sales Tracking** — Log and monitor sales over custom date ranges
- **Capital Management** — Record capital contributions and track totals
- **Expense Logging** — Track operational expenses
- **Profit Charts** — Visual trend analysis over the last 12 weeks
- **History** — Browse all entries with full transaction history
- **Responsive Layout** — Adapts to mobile, tablet, and desktop screens
- **Arabic UI** — Full RTL support with Cairo font
- **CSV Export** — Export your data for external analysis
- **Dark Theme** — Modern glassmorphism-inspired dark interface

## Screenshots

> _Screenshots coming soon_

<!-- Add screenshots here: -->
<!-- ![Dashboard](screenshots/dashboard.png) -->
<!-- ![History](screenshots/history.png) -->

---

## Build Instructions

### Linux

**Prerequisites:**
- Flutter SDK (3.47.2+)
- GTK 3 development libraries

```bash
# Install dependencies
sudo apt-get install -y libgtk-3-dev pkg-config cmake ninja-build clang

# Build
flutter build linux --release

# Run
./build/linux/x64/release/bundle/maksabi
```

### Windows

**Prerequisites:**
- Flutter SDK (3.47.2+)
- Visual Studio 2022+ with "Desktop development with C++" workload

```batch
build_windows.bat
```

Or manually:

```batch
flutter build windows --release
```

The built executable will be at `build\windows\x64\runner\Release\maksabi.exe`.

### Creating a Windows Installer

Requires [Inno Setup](https://jrsoftware.org/isdl.php):

```batch
create_installer.bat
```

Output: `build\installer\maksabi-setup-1.0.0.exe`

---

## Tech Stack

- **Framework:** Flutter
- **State Management:** Riverpod
- **Database:** Drift (SQLite)
- **Charts:** fl_chart
- **Fonts:** Google Fonts (Cairo)

---

## License

This project is private and not open source.
