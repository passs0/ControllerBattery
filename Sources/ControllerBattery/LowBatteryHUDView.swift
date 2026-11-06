import SwiftUI
import AppKit

public struct LowBatteryHUDView: View {
    public let controllerName: String
    public let batteryPercent: Int
    public let brand: ControllerBrand
    public var onDismiss: (() -> Void)? = nil

    private var systemControllerImage: NSImage? {
        let path = "/System/Library/PrivateFrameworks/CoreBluetoothUI.framework/Versions/A/Resources/Generic-GameController.png"
        return NSImage(contentsOfFile: path)
    }

    public init(controllerName: String, batteryPercent: Int, brand: ControllerBrand, onDismiss: (() -> Void)? = nil) {
        self.controllerName = controllerName
        self.batteryPercent = batteryPercent
        self.brand = brand
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(spacing: 14) {
            // Left Device Icon
            leadingIconView

            // Middle Text Description
            VStack(alignment: .leading, spacing: 2) {
                Text("Low Battery")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)

                Text("Plug-in soon to recharge")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 8)

            // Right Circular Battery Gauge (Matches Apple macOS accessory notification)
            circularGaugeView
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(minWidth: 260, maxWidth: 320)
        .background(
            ZStack {
                // Frosted vibrant glass capsule
                VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                    .clipShape(Capsule())

                // Subtle border stroke matching macOS HUD
                Capsule()
                    .stroke(Color.primary.opacity(0.12), lineWidth: 0.75)
            }
        )
        .shadow(color: Color.black.opacity(0.20), radius: 14, x: 0, y: 7)
        .contentShape(Capsule())
        .onTapGesture {
            onDismiss?()
        }
    }

    @ViewBuilder
    private var leadingIconView: some View {
        if let img = systemControllerImage {
            Image(nsImage: img)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 34, height: 26)
        } else {
            // Fallback to branded squircle
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(brand.brandColor)
                    .frame(width: 26, height: 26)
                Image(systemName: brand.iconName)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
        }
    }

    private var circularGaugeView: some View {
        let fraction = CGFloat(max(0.01, min(1.0, Double(batteryPercent) / 100.0)))

        return ZStack {
            // Circular background track
            Circle()
                .stroke(Color.primary.opacity(0.18), lineWidth: 2.5)
                .frame(width: 28, height: 28)

            // Red remaining battery arc
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    Color.red,
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 28, height: 28)

            // Centered battery percentage number (as seen in Image 1)
            Text("\(batteryPercent)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

// NSVisualEffectView wrapper for SwiftUI on macOS
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
