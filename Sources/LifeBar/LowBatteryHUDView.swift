import SwiftUI
import AppKit

public struct LowBatteryHUDView: View {
    public let controllerName: String
    public let batteryPercent: Int
    public let brand: ControllerBrand
    public var onDismiss: (() -> Void)? = nil

    /// Apple official built-in 3D game controller image from CoreBluetoothUI
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
        HStack(spacing: 12) {
            // Left Device Glyph (Apple built-in 3D gamepad)
            leadingIconView

            // Middle Description (Apple accessory low-battery typography)
            VStack(alignment: .leading, spacing: 1.5) {
                Text("Low Battery")
                    .font(.system(size: 13, weight: .semibold, design: .default))
                    .foregroundColor(.primary)

                Text("Plug-in soon to recharge")
                    .font(.system(size: 11, weight: .regular, design: .default))
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 10)

            // Right Circular Battery Gauge (Circular gauge with red arc & rounded number)
            circularGaugeView
        }
        .padding(.leading, 14)
        .padding(.trailing, 16)
        .padding(.vertical, 8)
        .frame(width: 296, height: 52)
        .background(
            ZStack {
                // Frosted translucent HUD glass capsule with explicit CALayer corner clipping
                VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow, cornerRadius: 26)

                // Delicate Apple specular inner rim
                Capsule()
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5)
            }
        )
        .clipShape(Capsule())
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
                .frame(width: 36, height: 26)
        } else {
            // Fallback to Apple branded squircle
            ZStack {
                RoundedRectangle(cornerRadius: 6.5, style: .continuous)
                    .fill(brand.brandGradient)
                    .frame(width: 28, height: 28)
                Image(systemName: brand.iconName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }

    private var circularGaugeView: some View {
        let fraction = CGFloat(max(0.01, min(1.0, Double(batteryPercent) / 100.0)))

        return ZStack {
            // Circular background track ring
            Circle()
                .stroke(Color.primary.opacity(0.16), lineWidth: 2.2)
                .frame(width: 26, height: 26)

            // Red remaining battery arc (Starts from 12 o'clock, sweeps clockwise)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    Color(red: 1.0, green: 0.27, blue: 0.23), // Apple System Red #FF453A
                    style: StrokeStyle(lineWidth: 2.2, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 26, height: 26)

            // Centered battery percentage integer in SF Pro Rounded
            Text("\(batteryPercent)")
                .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .monospacedDigit()
        }
    }
}

// NSVisualEffectView wrapper with hardware CALayer corner radius & masking
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var cornerRadius: CGFloat

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.wantsLayer = true
        view.layer?.cornerRadius = cornerRadius
        view.layer?.masksToBounds = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.wantsLayer = true
        nsView.layer?.cornerRadius = cornerRadius
        nsView.layer?.masksToBounds = true
    }
}
