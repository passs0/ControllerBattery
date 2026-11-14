<p align="center">
  <img src="assets/icon_mac.png" width="160" height="160" alt="LifeBar Icon" />
</p>

<h1 align="center">LifeBar</h1>

<p align="center">
  <strong>Never let your controller die mid-game.</strong><br/>
  Native macOS menu bar battery monitor & low-battery HUD for PlayStation DualSense, Xbox, Nintendo Switch, and MFi controllers.
</p>

<p align="center">
  <a href="https://github.com/passs0/LifeBar/releases/latest"><img src="https://img.shields.io/github/v/release/passs0/LifeBar?label=Latest%20Release&color=007AFF" alt="Latest Release" /></a>
  <img src="https://img.shields.io/badge/macOS-13.0%2B%20%7C%20Apple%20Silicon%20%26%20Intel-black?logo=apple" alt="macOS 13.0+" />
  <img src="https://img.shields.io/badge/framework-GameController%20%7C%20AppKit%20%7C%20SwiftUI-blue" alt="Frameworks" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License" /></a>
</p>

<p align="center">
  <img src="assets/hud.png" width="340" alt="LifeBar Low-Battery HUD" />
  <br/><br/>
  <img src="assets/popover.png" width="340" alt="LifeBar Menu Bar Popover" />
</p>

---

> [!NOTE]
> **AI-Generated Project Disclosure**
> **LifeBar** (including its Swift architecture, `GameController` observation, non-activating HUD panel, and Apple HIG squircle icon) is an **AI-generated project** created with **Antigravity** (Google DeepMind).

---

## Features

- **Menu Bar Status Item (`LSUIElement`):** Sits quietly in your menu bar using Apple's `gamecontroller` SF Symbol with optional live percentage display, hover tooltip, and zero Dock clutter.
- **Broad Controller Support:** Uses `GameController.framework` for PlayStation (DualSense, DualSense Edge, DualShock 4), Xbox (Wireless, Elite Series 2), Nintendo (Switch Pro, Joy-Cons), and MFi/HID gamepads.
- **Non-Activating Low-Battery HUD:** Floating frosted capsule (`NSPanel`) with Apple's circular gauge ring, alert sound, and Notification Center mirroring that never steals focus from full-screen games.
- **Smart Threshold & System Integration:** Configurable 5%–35% alert threshold, one-click test button, Launch at Login (`SMAppService`), and automatic refresh on system wake.

## Installation

### Download Release
1. Download **`LifeBar-v1.1.1.dmg`** from [GitHub Releases](https://github.com/passs0/LifeBar/releases/latest) and drag **`LifeBar.app`** to `/Applications`.
2. On first launch, right-click `LifeBar.app` ➔ **Open**, or run `xattr -cr /Applications/LifeBar.app`.

### Build from Source
```zsh
git clone https://github.com/passs0/LifeBar.git && cd LifeBar
make install
```

## License

Released under the [MIT License](LICENSE).
