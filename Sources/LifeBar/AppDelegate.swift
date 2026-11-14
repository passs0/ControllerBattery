import AppKit
import SwiftUI
import Combine

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var eventMonitor: Any?
    private var cancellables = Set<AnyCancellable>()
    private var normalImage: NSImage?
    private var activeImage: NSImage?

    public func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        setupBindings()
    }

    private func symbolImage(named symbolName: String) -> NSImage? {
        let symbolConfig = NSImage.SymbolConfiguration(pointSize: 14.5, weight: .regular)
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Game Controllers")?
            .withSymbolConfiguration(symbolConfig)
        image?.isTemplate = true
        return image
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        normalImage = symbolImage(named: "gamecontroller")
        activeImage = symbolImage(named: "gamecontroller.fill")

        if let button = statusItem.button {
            button.image = normalImage
            button.alternateImage = activeImage
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

    private func updateStatusItemImage(isActive: Bool) {
        guard let button = statusItem.button else { return }
        button.image = isActive ? activeImage : normalImage
    }

    private func updateStatusItem() {
        guard let button = statusItem.button else { return }

        button.toolTip = ControllerManager.shared.statusItemTooltip
        updateStatusItemImage(isActive: popover?.isShown ?? false)

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

        updateStatusItemImage(isActive: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        button.highlight(true)
        popover.contentViewController?.view.window?.makeKey()
    }

    private func closePopover() {
        popover.performClose(nil)
        updateStatusItemImage(isActive: false)
        statusItem.button?.highlight(false)
    }

    // MARK: - NSPopoverDelegate (Apple native status item highlight)

    public func popoverWillShow(_ notification: Notification) {
        updateStatusItemImage(isActive: true)
        statusItem.button?.highlight(true)
    }

    public func popoverDidClose(_ notification: Notification) {
        updateStatusItemImage(isActive: false)
        statusItem.button?.highlight(false)
    }

    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
