<p align="center">
  <img src="assets/icon_mac.png" width="160" height="160" alt="LifeBar Icon" />
</p>

<h1 align="center">LifeBar</h1>

<p align="center">
  <strong>Never let your controller die mid-game.</strong><br/>
  Native macOS menu bar battery monitor & accessory low-battery HUD for PlayStation DualSense, Xbox, Nintendo Switch, and MFi controllers.
</p>

<p align="center">
  <a href="https://github.com/passs0/LifeBar/releases/latest"><img src="https://img.shields.io/github/v/release/passs0/LifeBar?label=Latest%20Release&color=007AFF" alt="Latest Release" /></a>
  <img src="https://img.shields.io/badge/version-1.1.1-blue" alt="Version 1.1.1" />
  <img src="https://img.shields.io/badge/macOS-13.0%2B%20%7C%20Apple%20Silicon%20%26%20Intel-black?logo=apple" alt="macOS 13.0+" />
  <img src="https://img.shields.io/badge/framework-GameController%20%7C%20AppKit%20%7C%20SwiftUI-blue" alt="Frameworks" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License" /></a>
</p>

---

> [!NOTE]
> **AI-Generated Project Disclosure**
> **LifeBar** (including its Swift architecture, GameController framework observation, AppKit non-activating HUD panel, reverse-engineered macOS accessory battery notification layout, and Apple HIG dark mode squircle icon) is an **AI-generated project** created with **Antigravity** (Google DeepMind).

---

## ✨ Why LifeBar?

macOS displays a brief system banner when a game controller connects via Bluetooth, but **it provides no persistent menu bar battery monitor and does not alert you when a controller battery drops low during a game**.

To check your battery level, you usually have to leave your game, open **System Settings**, navigate to the **Game Controllers** pane, and squint at the subline. When the battery runs out, the controller simply shuts off mid-action without warning—costing you a boss fight or clutch multiplayer round.

**LifeBar fills that gap with a focused menu bar utility:**
- **Instant Menu Bar Glanceability:** Sits quietly in your menu bar using Apple's official SF Symbol `gamecontroller` glyph, with optional live percentage display and zero Dock clutter (`LSUIElement`).
- **Compact Controller List:** Shows connected devices, charging state, and battery level in a simple system-style list.
- **Low-Battery Alert:** Shows a compact custom alert and can mirror it to Notification Center when a controller crosses your chosen threshold.

---

## 🚀 Features

### 1. Menu Bar Status Item (Zero Dock Clutter)
- Uses Apple's official SF Symbol `gamecontroller` glyph with automatic Dark/Light menu bar template adaptation.
- Highlights with macOS's native accent selection pill while the menu is open (`NSPopoverDelegate`).
- Runs as a lightweight macOS agent app (`LSUIElement = true`) with low-frequency controller polling.
- Optional toggle to display the battery percentage directly in the menu bar next to the icon.
- Hover tooltip showing all connected controllers and their individual battery percentages.

### 2. Compact Controller List
- Uses Apple's `GameController.framework` (`GCController`) for reliable detection of wireless (Bluetooth) and wired game controllers:
  - **Sony PlayStation:** DualSense, DualSense Edge, DualShock 4.
  - **Microsoft Xbox:** Xbox Wireless Controller, Xbox Elite Series 2.
  - **Nintendo:** Switch Pro Controller and Joy-Cons.
  - **MFi & HID Gamepads:** 8BitDo, Backbone One, Razer, SteelSeries, and others.
- Displays connection status, live battery level, and charging state with concise text and symbols.

### 3. Low-Battery HUD Alert
- Shows a compact custom alert when a controller falls below the selected threshold:
  - **Floating Frosted Capsule:** Borderless, non-activating `NSPanel` floating smoothly at the top of your screen below the notch/menu bar.
  - **Built-in Controller Glyph:** Uses Apple's official 3D controller asset (`Generic-GameController.png` from `CoreBluetoothUI`).
  - **Apple Circular Gauge Ring:** Circular track, remaining battery arc in red, and centered battery percentage number in SF Pro Rounded.
  - **Audio & System Integration:** Accompanied by macOS alert sound (`Sosumi`) and mirrored to macOS Notification Center.
- **Smart Deduplication:** Alerts once per discharge cycle; will not spam repeatedly while in the low-battery state.
- **One-Click Test:** Includes a **"Test Low Battery Notification"** button to preview the exact HUD alert anytime.

### 4. Deep System Integration & Convenience
- **Alert Threshold:** Set a low-battery threshold from 5% to 35% in 5% increments, with the selected value shown alongside the system slider.
- **Quick Settings Access:** One-click shortcut jumping directly to the macOS Game Controllers settings pane.
- **Launch at Login:** Native integration with Apple's modern `SMAppService` API.
- **Sleep & Wake Resilient:** Automatically refreshes connections and polling upon system wake.

---

## 📦 Installation & Getting Started

### Recommended: Pre-Built Release

1. **Download the App**:
   Go to the [**Releases**](https://github.com/passs0/LifeBar/releases/latest) page and download **`LifeBar-v1.1.1.dmg`**.
2. **Move to Applications**:
   Open the disk image and drag **`LifeBar.app`** directly into your **`/Applications`** folder.
3. **First-Launch Gatekeeper Clearance (macOS)**:
   Because the app is ad-hoc signed, run the following command once in Terminal (or right-click -> **Open** in Finder) to clear the macOS quarantine attribute:
   ```bash
   xattr -cr /Applications/LifeBar.app
   ```
4. **Launch & Connect**:
   - Open **`LifeBar`** from Applications, Spotlight, or Launchpad.
   - Pair or turn on your game controller — the battery level will appear instantly in your menu bar!

---

## 🛠️ Architecture & Under the Hood

```
LifeBar/
├── Package.swift                               # Swift package definition (macOS 13+)
├── Info.plist                                  # Bundle configuration (LSUIElement = true)
├── Makefile                                    # Convenient build & install targets
├── build.sh                                    # Release packaging & ad-hoc codesigning script
├── generate_icns.sh                            # Multi-resolution Retina AppIcon compiler
├── assets/
│   └── icon.png                                # macOS Sequoia Dark Mode vector app icon
└── Sources/
    └── LifeBar/
        ├── main.swift                          # Main entry point & NSApplication lifecycle
        ├── AppDelegate.swift                   # NSStatusItem & NSPopover coordinator
        ├── ControllerManager.swift             # GameController observation & battery monitoring
        ├── ControllerModel.swift               # Brand detection, SF Symbols & battery formatting
        ├── MenuView.swift                      # SwiftUI popover matching System Settings
        ├── LowBatteryHUDController.swift       # Floating NSPanel HUD presentation & animation
        └── LowBatteryHUDView.swift             # Frosted glass capsule & circular gauge view
```

- **`GCController` Lifecycle:** Listens to `.GCControllerDidConnect` and `.GCControllerDidDisconnect` notifications, coupled with low-frequency (6s) battery polling that incurs zero perceptible system load.
- **Non-Activating HUD Window:** `LowBatteryHUDController` manages an `NSPanel` with `.nonactivatingPanel` and collection behavior `[.canJoinAllSpaces, .fullScreenAuxiliary]`, ensuring full-screen games never lose focus when the low-battery warning appears.

---

## ⌨️ Building from Source

Ensure you have **Xcode Command Line Tools** and **Swift 5.9+** installed. Xcode 26 or later is needed to compile the four-appearance icon catalog; without `actool`, a local build uses the static fallback icon.

```bash
# Clone the repository
git clone https://github.com/passs0/LifeBar.git
cd LifeBar

# Build the release app bundle
make app

# Run the app
make run

# Install to /Applications
make install
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

See [release notes](RELEASE_NOTES.md) and the [roadmap](ROADMAP.md).
