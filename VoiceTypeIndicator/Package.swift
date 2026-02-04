// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "VoiceTypeIndicator",
    platforms: [
        .macOS(.v12)
    ],
    targets: [
        .executableTarget(
            name: "VoiceTypeIndicator",
            path: "VoiceTypeIndicator",
            exclude: ["Info.plist"]
        )
    ]
)
