import SwiftUI
import ServiceManagement

public struct MenuView: View {
    @ObservedObject var manager = ControllerManager.shared
    @State private var launchAtLogin: Bool = (SMAppService.mainApp.status == .enabled)
    @State private var isThresholdHovered: Bool = false
    public var previewControllers: [ControllerDevice]? = nil

    private var activeControllers: [ControllerDevice] {
        previewControllers ?? manager.controllers
    }

    public init(previewControllers: [ControllerDevice]? = nil) {
        self.previewControllers = previewControllers
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            headerView
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

            Divider()
                .opacity(0.4)

            // Controllers List or Empty State
            VStack(spacing: 8) {
                if activeControllers.isEmpty {
                    emptyStateView
                        .padding(.vertical, 16)
                } else {
                    ForEach(activeControllers) { controller in
                        controllerCard(controller)
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 12)

            Divider()
                .opacity(0.4)

            // Quick Actions & Controls (Apple Control Center style)
            VStack(alignment: .leading, spacing: 2) {
                // Test Low Battery Alert
                MenuActionRow(
                    icon: "bell.badge.fill",
                    iconColor: .orange,
                    title: "Test Low Battery Notification"
                ) {
                    manager.triggerTestAlert()
                }

                // Show Percentage in Menu Bar
                MenuToggleRow(
                    icon: "percent",
                    iconColor: .secondary,
                    title: "Show Percentage in Menu Bar",
                    isOn: $manager.showPercentageInMenuBar
                )

                // Low Battery Alert Threshold Slider (Apple Battery Health style)
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        Image(systemName: "slider.horizontal.2")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 20)

                        Text("Alert Threshold")
                            .font(.system(size: 12.5))
                            .foregroundColor(.primary)

                        Spacer()

                        Text("\(manager.lowBatteryThreshold)%")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Color.primary.opacity(0.06))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 8) {
                        Text("5%")
                            .font(.system(size: 9.5, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.6))

                        Slider(
                            value: Binding(
                                get: { Double(manager.lowBatteryThreshold) },
                                set: { manager.lowBatteryThreshold = Int($0) }
                            ),
                            in: 5...35,
                            step: 5
                        )
                        .controlSize(.small)

                        Text("35%")
                            .font(.system(size: 9.5, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    .padding(.leading, 30)
                    .padding(.trailing, 4)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(isThresholdHovered ? Color.primary.opacity(0.08) : Color.clear)
                )
                .onHover { hovering in
                    isThresholdHovered = hovering
                }

                // Launch at Login Switch
                MenuToggleRow(
                    icon: "arrow.clockwise",
                    iconColor: .secondary,
                    title: "Launch at Login",
                    isOn: Binding(
                        get: { launchAtLogin },
                        set: { newValue in
                            launchAtLogin = newValue
                            setLaunchAtLogin(enabled: newValue)
                        }
                    )
                )

                // Open System Settings Game Controller Pane
                MenuActionRow(
                    icon: "gearshape",
                    iconColor: .secondary,
                    title: "Game Controller Settings…"
                ) {
                    openGameControllerSettings()
                } accessory: {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)

            Divider()
                .opacity(0.4)

            // Footer Quit Action
            HStack {
                MenuActionRow(
                    icon: "power",
                    iconColor: .secondary,
                    title: "Quit LifeBar"
                ) {
                    NSApplication.shared.terminate(nil)
                } accessory: {
                    Text("⌘Q")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.8))
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
        }
        .frame(width: 320)
        .onAppear {
            manager.refreshControllers()
            launchAtLogin = (SMAppService.mainApp.status == .enabled)
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 8) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            Text("Game Controllers")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)

            Spacer()

            if activeControllers.isEmpty {
                Text("No Devices")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.06))
                    .clipShape(Capsule())
            } else {
                HStack(spacing: 4.5) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)

                    Text("\(activeControllers.count) Connected")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2.5)
                .background(Color.primary.opacity(0.06))
                .clipShape(Capsule())
            }
        }
    }

    // MARK: - Controller Card (Matches Image 2 & System Settings)
    private func controllerCard(_ controller: ControllerDevice) -> some View {
        HStack(spacing: 12) {
            // Squircle Brand Icon (Matches macOS Settings Image 2)
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(controller.brand.brandGradient)
                    .frame(width: 36, height: 36)
                    .shadow(color: controller.brand.brandColor.opacity(0.30), radius: 3, y: 1.5)

                Image(systemName: controller.brand.iconName)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
            }

            // Info Details
            VStack(alignment: .leading, spacing: 2.5) {
                Text(controller.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack(spacing: 5) {
                    Text("Connected -")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Image(systemName: controller.batterySymbolName)
                        .font(.system(size: 11.5))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(
                            controller.isLowBattery ? .red :
                            (controller.isCharging ? .green : .secondary)
                        )

                    if let percent = controller.batteryPercent {
                        Text(controller.isCharging ? "Battery \(percent)% (Charging)" : "Battery \(percent)%")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Mini Battery Gauge (Apple Battery Widget Circular Arc)
            if let percent = controller.batteryPercent {
                let fraction = CGFloat(max(0.01, min(1.0, Double(percent) / 100.0)))

                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.12), lineWidth: 2.2)
                        .frame(width: 24, height: 24)

                    Circle()
                        .trim(from: 0, to: fraction)
                        .stroke(
                            controller.isLowBattery ? Color.red :
                            (controller.isCharging ? Color.green : Color.primary.opacity(0.7)),
                            style: StrokeStyle(lineWidth: 2.2, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 24, height: 24)

                    Text("\(percent)")
                        .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                        .foregroundColor(controller.isLowBattery ? .red : .primary)
                        .monospacedDigit()
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.65))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color(nsColor: .separatorColor).opacity(0.4), lineWidth: 0.5)
        )
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 6) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(.secondary.opacity(0.5))

            Text("No Controllers Connected")
                .font(.system(size: 12.5, weight: .medium))
                .foregroundColor(.primary.opacity(0.85))

            Text("Connect a Bluetooth controller or plug in via USB")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
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

// MARK: - Apple Style Menu Components

struct MenuActionRow<Accessory: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void
    let accessory: () -> Accessory

    @State private var isHovered = false

    init(
        icon: String,
        iconColor: Color = .secondary,
        title: String,
        action: @escaping () -> Void,
        @ViewBuilder accessory: @escaping () -> Accessory = { EmptyView() }
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.action = action
        self.accessory = accessory
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: 20)

                Text(title)
                    .font(.system(size: 12.5))
                    .foregroundColor(.primary)

                Spacer()

                accessory()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isHovered ? Color.primary.opacity(0.08) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct MenuToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 20)

            Text(title)
                .font(.system(size: 12.5))
                .foregroundColor(.primary)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.mini)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 3.5)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isHovered ? Color.primary.opacity(0.08) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
