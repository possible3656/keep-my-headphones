// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KeepMyHeadphones",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "KeepMyHeadphones",
            targets: ["KeepMyHeadphones"]
        )
    ],
    targets: [
        .executableTarget(
            name: "KeepMyHeadphones",
            dependencies: [],
            path: "Sources"
        )
    ]
)

