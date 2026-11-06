# ControllerBattery 🎮🔋

A lightweight, native macOS menu bar app for tracking connected game controllers (Bluetooth and wired) and their battery levels, featuring macOS-native low-battery HUD notifications.

---

## ✨ Features

- **Menu Bar Status Item**: Uses Apple's SF Symbol `gamecontroller` glyph in the macOS menu bar. Runs cleanly as an accessory agent (`LSUIElement`) with no Dock clutter.
- **Controller List Popover**:
  - Displays all connected wireless and wired controllers (DualSense, DualShock 4, Xbox Wireless Controller, Nintendo Switch Pro Controller, Joy-Cons, MFi, and HID gamepads).
  - Branded squircle icons matching macOS System Settings (PlayStation Blue, Xbox Green, Nintendo Red).
  - Live battery percentage and charging state (`Connected - ⚡️ Battery 55%`).
  - Visual battery level indicators.
- **macOS-Style Low-Battery HUD Notification**:
  - Exact recreation of Apple's accessory low-battery notification pill.
  - Floating translucent frosted glass capsule at the top of the display.
  - Built-in controller glyph, "Low Battery", and "Plug-in soon to recharge".
  - Circular battery gauge with red progress arc and centered percentage number.
  - Accompanied by macOS alert sound and Notification Center banner.
- **Customizable Alert Threshold**: Choose when to be notified (10%, 15%, 20%, or 25%).
- **Optional Menu Bar Percentage**: Toggle showing the battery percentage directly next to the menu bar controller glyph.
- **One-Click Settings Access**: Jump straight into the macOS Game Controllers settings pane.
- **Launch at Login**: Easily enable or disable automatic launch on system startup.
- **Custom App Icon Ready**: Prepared `Resources` folder ready for your custom `AppIcon.icns`.

---

## 🚀 Building & Running

### Option 1: Using Make
```bash
# Build and package into ControllerBattery.app
make app

# Launch the app
make run

# Optional: Install to /Applications
make install
```

### Option 2: Using the build script
```bash
./build.sh
open build/ControllerBattery.app
```

---

## 🎨 Adding Your App Icon

When you are ready with your app icon:
1. Save your icon as `AppIcon.icns`.
2. Place it either in the project root or in `build/ControllerBattery.app/Contents/Resources/AppIcon.icns`.
3. If placing in the project root, re-run `./build.sh` — the script will automatically include it in the bundle.

---

## 🛠️ Architecture

- **`ControllerManager.swift`**: Uses Apple's `GameController.framework` (`GCController`) to observe controller connections, disconnections, and live battery states (`GCDeviceBattery`).
- **`ControllerModel.swift`**: Identifies controller brands (Sony PlayStation, Microsoft Xbox, Nintendo, generic) and maps their corresponding brand colors and SF Symbols.
- **`MenuView.swift`**: SwiftUI-based popover interface styled to match macOS System Settings.
- **`LowBatteryHUDController.swift` & `LowBatteryHUDView.swift`**: Manages the floating, non-activating `NSPanel` presenting the animated low-battery notification pill.
- **`AppDelegate.swift`**: Configures the `NSStatusItem`, popover behavior, and sleep/wake listeners.

---

## 🤖 AI-Use Declaration

This project was developed with the assistance of artificial intelligence (Google DeepMind / Antigravity Agentic AI), assisting in the Swift architecture, GameController framework integration, AppKit/SwiftUI HUD notification engineering, reverse-engineering of macOS accessory HUD layouts, and the Apple Human Interface Design icon generation.

