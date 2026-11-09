import AppKit
import SwiftUI

@main
struct RenderScreenshots {
    @MainActor
    static func main() {
        let mockDevice = ControllerDevice(
            id: "preview_dualsense",
            name: "DualSense Wireless Controller",
            category: "DualSense",
            brand: .playStation,
            batteryLevel: 0.55,
            batteryState: .discharging,
            isAttachedToDevice: false
        )

        // 1. RENDER ACTUAL MENU VIEW POPOVER
        let popoverContent = MenuView(previewControllers: [mockDevice])
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(red: 0.13, green: 0.13, blue: 0.15, opacity: 0.96))
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .preferredColorScheme(.dark)

        let popHosting = NSHostingView(rootView: popoverContent)
        let popSize = CGSize(width: 320, height: popHosting.fittingSize.height)
        popHosting.frame = NSRect(origin: .zero, size: popSize)
        popHosting.wantsLayer = true
        popHosting.layer?.backgroundColor = NSColor.clear.cgColor

        let popWindow = NSWindow(contentRect: NSRect(origin: .zero, size: popSize),
                                 styleMask: [.borderless],
                                 backing: .buffered,
                                 defer: false)
        popWindow.backgroundColor = .clear
        popWindow.isOpaque = false
        popWindow.hasShadow = false
        popWindow.contentView = popHosting
        popWindow.display()

        let popImg = NSImage(size: popSize)
        if let rep = popHosting.bitmapImageRepForCachingDisplay(in: popHosting.bounds) {
            popHosting.cacheDisplay(in: popHosting.bounds, to: rep)
            popImg.addRepresentation(rep)
        }

        // Draw onto padded canvas with smooth shadow along vector rounded rect path
        let popPad: CGFloat = 30
        let popCanvasSize = CGSize(width: popSize.width + popPad * 2, height: popSize.height + popPad * 2)
        let popCanvas = NSImage(size: popCanvasSize)
        popCanvas.lockFocus()
        if let ctx = NSGraphicsContext.current?.cgContext {
            ctx.clear(CGRect(origin: .zero, size: popCanvasSize))
            let shadowPath = CGPath(roundedRect: CGRect(x: popPad, y: popPad, width: popSize.width, height: popSize.height),
                                    cornerWidth: 14, cornerHeight: 14, transform: nil)
            ctx.saveGState()
            ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 22, color: NSColor.black.withAlphaComponent(0.40).cgColor)
            ctx.addPath(shadowPath)
            ctx.fillPath()
            ctx.restoreGState()

            popImg.draw(in: CGRect(x: popPad, y: popPad, width: popSize.width, height: popSize.height), from: .zero, operation: .sourceOver, fraction: 1.0)
        }
        popCanvas.unlockFocus()

        if let tiff = popCanvas.tiffRepresentation,
           let rep = NSBitmapImageRep(data: tiff),
           let png = rep.representation(using: .png, properties: [:]) {
            try? png.write(to: URL(fileURLWithPath: "/Users/pascal/.gemini/antigravity/scratch/LifeBar/assets/popover.png"))
            try? png.write(to: URL(fileURLWithPath: "/Users/pascal/.gemini/antigravity/brain/a2e2b031-f5de-4069-bd38-685f21ab768b/popover.png"))
            print("Successfully rendered actual MenuView popover to assets/popover.png")
        }

        // 2. RENDER ACTUAL HUD PILL NOTIFICATION
        let hudContent = LowBatteryHUDView(
            controllerName: "DualSense Wireless Controller",
            batteryPercent: 6,
            brand: .playStation
        )
        .preferredColorScheme(.dark)

        let hudSize = CGSize(width: 296, height: 52)
        let hudHosting = NSHostingView(rootView: hudContent)
        hudHosting.frame = NSRect(origin: .zero, size: hudSize)
        hudHosting.wantsLayer = true
        hudHosting.layer?.backgroundColor = NSColor.clear.cgColor

        let hudWindow = NSWindow(contentRect: NSRect(origin: .zero, size: hudSize),
                                 styleMask: [.borderless],
                                 backing: .buffered,
                                 defer: false)
        hudWindow.backgroundColor = .clear
        hudWindow.isOpaque = false
        hudWindow.hasShadow = false
        hudWindow.contentView = hudHosting
        hudWindow.display()

        let hudImg = NSImage(size: hudSize)
        if let rep = hudHosting.bitmapImageRepForCachingDisplay(in: hudHosting.bounds) {
            hudHosting.cacheDisplay(in: hudHosting.bounds, to: rep)
            hudImg.addRepresentation(rep)
        }

        let hudPad: CGFloat = 20
        let hudCanvasSize = CGSize(width: hudSize.width + hudPad * 2, height: hudSize.height + hudPad * 2)
        let hudCanvas = NSImage(size: hudCanvasSize)
        hudCanvas.lockFocus()
        if let ctx = NSGraphicsContext.current?.cgContext {
            ctx.clear(CGRect(origin: .zero, size: hudCanvasSize))
            let pillPath = CGPath(roundedRect: CGRect(x: hudPad, y: hudPad, width: hudSize.width, height: hudSize.height),
                                  cornerWidth: 26, cornerHeight: 26, transform: nil)
            ctx.saveGState()
            ctx.setShadow(offset: CGSize(width: 0, height: -6), blur: 16, color: NSColor.black.withAlphaComponent(0.35).cgColor)
            ctx.addPath(pillPath)
            ctx.fillPath()
            ctx.restoreGState()

            hudImg.draw(in: CGRect(x: hudPad, y: hudPad, width: hudSize.width, height: hudSize.height), from: .zero, operation: .sourceOver, fraction: 1.0)
        }
        hudCanvas.unlockFocus()

        if let tiff = hudCanvas.tiffRepresentation,
           let rep = NSBitmapImageRep(data: tiff),
           let png = rep.representation(using: .png, properties: [:]) {
            try? png.write(to: URL(fileURLWithPath: "/Users/pascal/.gemini/antigravity/scratch/LifeBar/assets/hud.png"))
            try? png.write(to: URL(fileURLWithPath: "/Users/pascal/.gemini/antigravity/brain/a2e2b031-f5de-4069-bd38-685f21ab768b/hud.png"))
            print("Successfully rendered actual LowBatteryHUDView pill to assets/hud.png")
        }
    }
}
