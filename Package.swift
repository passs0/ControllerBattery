// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LifeBar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "LifeBar",
            targets: ["LifeBar"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "LifeBar",
            path: "Sources/LifeBar"
        ),
    ]
)
