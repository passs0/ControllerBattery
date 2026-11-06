import SwiftUI
import ServiceManagement

public struct MenuView: View {
    @ObservedObject var manager = ControllerManager.shared
    @State private var launchAtLogin: Bool = (SMAppService.mainApp.status == .enabled)

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            headerView
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

            Divider()

            // Controllers List or Empty State
            VStack(spacing: 8) {
                if manager.controllers.isEmpty {
                    emptyStateView
                        .padding(.vertical, 20)
                } else {
                    ForEach(manager.controllers) { controller in
                        controllerCard(controller)
                    }
                    .padding(.vertical, 10)
                }
            }
            .padding(.horizontal, 14)

            Divider()

            // Quick Actions & Settings
            VStack(alignment: .leading, spacing: 4) {
                // Test Low Battery Alert Button
                Button(action: {
                    manager.triggerTestAlert()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "bell.badge")
                            .frame(width: 18)
                            .foregroundColor(.orange)
                        Text("Test Low Battery Notification")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainHoverButtonStyle())

                // Open System Settings Game Controller Pane
                Button(action: {
                    openGameControllerSettings()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "gearshape")
                            .frame(width: 18)
                            .foregroundColor(.secondary)
                        Text("Game Controller Settings…")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainHoverButtonStyle())

                // Low Battery Threshold Picker
                HStack(spacing: 10) {
                    Image(systemName: "battery.25percent")
                        .frame(width: 18)
                        .foregroundColor(.secondary)
                    Text("Alert Threshold")
                    Spacer()
                    Picker("", selection: $manager.lowBatteryThreshold) {
                        Text("10%").tag(10)
                        Text("15%").tag(15)
                        Text("20%").tag(20)
                        Text("25%").tag(25)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 80)
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 8)

                // Show percentage in menu bar toggle
                Toggle(isOn: $manager.showPercentageInMenuBar) {
                    HStack(spacing: 10) {
                        Image(systemName: "percent")
                            .frame(width: 18)
                            .foregroundColor(.secondary)
                        Text("Show Level in Menu Bar")
                    }
                }
                .toggleStyle(CheckboxToggleStyle())
                .padding(.vertical, 2)
                .padding(.horizontal, 8)

                // Launch at login toggle
                Toggle(isOn: Binding(
                    get: { launchAtLogin },
                    set: { newValue in
                        launchAtLogin = newValue
                        setLaunchAtLogin(enabled: newValue)
                    }
                )) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise")
                            .frame(width: 18)
                            .foregroundColor(.secondary)
                        Text("Launch at Login")
                    }
                }
                .toggleStyle(CheckboxToggleStyle())
                .padding(.vertical, 2)
                .padding(.horizontal, 8)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 8)

            Divider()

            // Quit
            HStack {
                Spacer()
                Button("Quit ControllerBattery") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(PlainHoverButtonStyle())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .frame(width: 320)
        .onAppear {
            manager.refreshControllers()
            launchAtLogin = (SMAppService.mainApp.status == .enabled)
        }
    }

    private var headerView: some View {
        HStack(spacing: 8) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 15, weight: .medium))
            Text("Game Controllers")
                .font(.system(size: 13, weight: .semibold))
            Spacer()
            Text("\(manager.controllers.count) Connected")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.primary.opacity(0.08))
                .clipShape(Capsule())
        }
    }

    private func controllerCard(_ controller: ControllerDevice) -> some View {
        HStack(spacing: 12) {
            // Brand Squircle Icon (Matches macOS Settings Image 2)
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(controller.brand.brandColor)
                    .frame(width: 36, height: 36)

                Image(systemName: controller.brand.iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(controller.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack(spacing: 5) {
                    Text("Connected -")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Image(systemName: controller.batterySymbolName)
                        .font(.system(size: 12))
                        .foregroundColor(controller.isLowBattery ? .red : (controller.isCharging ? .green : .secondary))

                    if let percent = controller.batteryPercent {
                        Text("Battery \(percent)%")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Right Battery Meter or Percentage Badge
            if let percent = controller.batteryPercent {
                ZStack {
                    Capsule()
                        .fill(Color.primary.opacity(0.08))
                        .frame(width: 44, height: 20)

                    Text("\(percent)%")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(controller.isLowBattery ? .red : .primary)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.6))
            Text("No Controllers Connected")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            Text("Connect a controller via Bluetooth or USB")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }

    private func openGameControllerSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Game-Controllers-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }

    private func setLaunchAtLogin(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error)")
        }
    }
}

// Hover button style for macOS menu look
struct PlainHoverButtonStyle: ButtonStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isHovered ? Color.primary.opacity(0.08) : Color.clear)
            )
            .onHover { hovering in
                isHovered = hovering
            }
    }
}
