// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ControllerBattery",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ControllerBattery",
            targets: ["ControllerBattery"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "ControllerBattery",
            path: "Sources/ControllerBattery"
        ),
    ]
)
