import AppKit
import SwiftUI
import UserNotifications

@MainActor
public final class LowBatteryHUDController {
    public static let shared = LowBatteryHUDController()

    private var hudPanel: NSPanel?
    private var dismissWorkItem: DispatchWorkItem?

    private init() {
        requestNotificationPermission()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    public func show(controllerName: String, batteryPercent: Int, brand: ControllerBrand) {
        // Cancel existing dismiss timer
        dismissWorkItem?.cancel()

        // 1. Post native UNUserNotification for system Notification Center history
        postSystemNotification(name: controllerName, percent: batteryPercent)

        // 2. Play macOS standard alert sound
        if let sound = NSSound(named: "Sosumi") ?? NSSound(named: "Basso") {
            sound.play()
        }

        // 3. Create or reuse floating HUD panel
        let pillWidth: CGFloat = 296
        let pillHeight: CGFloat = 52

        let panel: NSPanel
        if let existing = hudPanel {
            panel = existing
        } else {
            panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: pillWidth, height: pillHeight),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            panel.isFloatingPanel = true
            panel.level = .floating
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = false
            panel.ignoresMouseEvents = false
            self.hudPanel = panel
        }

        let hudView = LowBatteryHUDView(
            controllerName: controllerName,
            batteryPercent: batteryPercent,
            brand: brand
        ) { [weak self] in
            self?.dismiss()
        }

        let hostingView = NSHostingView(rootView: hudView)
        hostingView.frame = NSRect(x: 0, y: 0, width: pillWidth, height: pillHeight)
        panel.contentView = hostingView

        // Position panel at top center of main screen (directly below notch/menu bar)
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame

        // Top inset accommodates MacBook notch (macOS 12+) or standard menu bar
        let topInset = max(screenFrame.maxY - visibleFrame.maxY, 28)
        let targetX = screenFrame.origin.x + (screenFrame.width - pillWidth) / 2.0
        let targetY = screenFrame.maxY - topInset - pillHeight - 8
        let startY = screenFrame.origin.y + screenFrame.height + 15

        panel.setFrame(NSRect(x: targetX, y: startY, width: pillWidth, height: pillHeight), display: true)
        panel.alphaValue = 0.0
        panel.orderFrontRegardless()

        // Apple fluid spring entrance animation
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.48
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.16, 1.0, 0.3, 1.0)
            panel.animator().setFrame(NSRect(x: targetX, y: targetY, width: pillWidth, height: pillHeight), display: true)
            panel.animator().alphaValue = 1.0
        }

        // Auto dismiss after 5.5 seconds
        let work = DispatchWorkItem { [weak self] in
            self?.dismiss()
        }
        self.dismissWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5, execute: work)
    }

    public func dismiss() {
        dismissWorkItem?.cancel()
        dismissWorkItem = nil

        guard let panel = hudPanel else { return }
        guard let screen = panel.screen ?? NSScreen.main else {
            panel.orderOut(nil)
            return
        }

        let screenFrame = screen.frame
        let offscreenY = screenFrame.origin.y + screenFrame.height + 20

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.32
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            var frame = panel.frame
            frame.origin.y = offscreenY
            panel.animator().setFrame(frame, display: true)
            panel.animator().alphaValue = 0.0
        }, completionHandler: { [weak self] in
            Task { @MainActor [weak self] in
                panel.orderOut(nil)
                self?.hudPanel = nil
            }
        })
    }

    private func postSystemNotification(name: String, percent: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Low Battery"
        content.subtitle = "\(name) (\(percent)%)"
        content.body = "Plug-in soon to recharge"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "low_battery_\(name)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { _ in }
    }
}
