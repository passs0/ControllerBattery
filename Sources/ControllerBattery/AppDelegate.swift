import AppKit
import SwiftUI
import Combine

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var eventMonitor: Any?
    private var cancellables = Set<AnyCancellable>()

    public func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        setupBindings()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            let symbolConfig = NSImage.SymbolConfiguration(pointSize: 14.5, weight: .regular)
            let image = NSImage(systemSymbolName: "gamecontroller", accessibilityDescription: "Game Controllers")?
                .withSymbolConfiguration(symbolConfig)
            image?.isTemplate = true
            button.image = image
            button.imagePosition = .imageLeft
            button.target = self
            button.action = #selector(togglePopover(_:))
            button.toolTip = ControllerManager.shared.statusItemTooltip
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.delegate = self

        let host = NSHostingController(rootView: MenuView())
        popover.contentViewController = host
        popover.contentSize = host.view.fittingSize
    }

    private func setupBindings() {
        ControllerManager.shared.$controllers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatusItem()
            }
            .store(in: &cancellables)

        ControllerManager.shared.$showPercentageInMenuBar
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatusItem()
            }
            .store(in: &cancellables)

        // Close popover when clicking outside
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in
                if let self = self, self.popover.isShown {
                    self.closePopover()
                }
            }
        }

        // Refresh on system wake
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                ControllerManager.shared.refreshControllers()
                ControllerManager.shared.startDiscovery()
            }
        }
    }

    private func updateStatusItem() {
        guard let button = statusItem.button else { return }

        button.toolTip = ControllerManager.shared.statusItemTooltip

        if let text = ControllerManager.shared.statusItemText {
            button.title = " \(text)"
        } else {
            button.title = ""
        }
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem.button else { return }
        ControllerManager.shared.refreshControllers()

        if let host = popover.contentViewController as? NSHostingController<MenuView> {
            popover.contentSize = host.view.fittingSize
        }

        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        button.highlight(true)
        popover.contentViewController?.view.window?.makeKey()
    }

    private func closePopover() {
        popover.performClose(nil)
        statusItem.button?.highlight(false)
    }

    // MARK: - NSPopoverDelegate (Apple native status item highlight)

    public func popoverWillShow(_ notification: Notification) {
        statusItem.button?.highlight(true)
    }

    public func popoverDidClose(_ notification: Notification) {
        statusItem.button?.highlight(false)
    }

    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
