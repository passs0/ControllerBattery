import SwiftUI
import GameController

public enum ControllerBrand: String, CaseIterable, Identifiable {
    case playStation
    case xbox
    case nintendo
    case generic

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .playStation: return "PlayStation"
        case .xbox: return "Xbox"
        case .nintendo: return "Nintendo"
        case .generic: return "Controller"
        }
    }

    public var iconName: String {
        switch self {
        case .playStation:
            return "playstation.logo"
        case .xbox:
            return "xbox.logo"
        case .nintendo:
            return "gamecontroller.fill"
        case .generic:
            return "gamecontroller.fill"
        }
    }

    public var brandColor: Color {
        switch self {
        case .playStation:
            // Sony PlayStation Blue (#0070D1)
            return Color(red: 0.0, green: 0.44, blue: 0.88)
        case .xbox:
            // Xbox Green (#107C10)
            return Color(red: 0.06, green: 0.49, blue: 0.06)
        case .nintendo:
            // Nintendo Red (#E60012)
            return Color(red: 0.90, green: 0.12, blue: 0.15)
        case .generic:
            return Color(red: 0.35, green: 0.40, blue: 0.50)
        }
    }
}

public struct ControllerDevice: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let category: String
    public let brand: ControllerBrand
    public let batteryLevel: Float? // 0.0 ... 1.0, nil if not reported
    public let batteryState: GCDeviceBattery.State
    public let isAttachedToDevice: Bool

    public var batteryPercent: Int? {
        guard let level = batteryLevel else { return nil }
        return Int(round(level * 100))
    }

    public var isCharging: Bool {
        return batteryState == .charging
    }

    public var isFull: Bool {
        return batteryState == .full
    }

    public var isLowBattery: Bool {
        guard let level = batteryLevel else { return false }
        // Low battery if level <= threshold (default 20%) and not charging
        return level <= 0.20 && batteryState != .charging
    }

    public var batterySymbolName: String {
        if isCharging {
            return "battery.100percent.bolt"
        }
        guard let percent = batteryPercent else {
            return "battery.100percent"
        }
        switch percent {
        case 0..<15:
            return "battery.0percent"
        case 15..<40:
            return "battery.25percent"
        case 40..<65:
            return "battery.50percent"
        case 65..<90:
            return "battery.75percent"
        default:
            return "battery.100percent"
        }
    }

    public var batteryStatusText: String {
        guard let percent = batteryPercent else {
            return "Connected"
        }
        if isCharging {
            return "Connected - Battery \(percent)% (Charging)"
        } else if isFull {
            return "Connected - Battery 100% (Full)"
        } else {
            return "Connected - Battery \(percent)%"
        }
    }

    public static func detectBrand(name: String, category: String) -> ControllerBrand {
        let lowerName = name.lowercased()
        let lowerCat = category.lowercased()

        if lowerName.contains("dualsense") ||
           lowerName.contains("dualshock") ||
           lowerName.contains("playstation") ||
           lowerCat.contains("dualsense") ||
           lowerCat.contains("dualshock") {
            return .playStation
        }

        if lowerName.contains("xbox") || lowerCat.contains("xbox") {
            return .xbox
        }

        if lowerName.contains("switch") ||
           lowerName.contains("joy-con") ||
           lowerName.contains("nintendo") ||
           lowerCat.contains("switch") {
            return .nintendo
        }

        return .generic
    }
}
