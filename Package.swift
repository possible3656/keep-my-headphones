// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HeadphoneIssueService",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "HeadphoneIssueService",
            targets: ["HeadphoneIssueService"]
        )
    ],
    targets: [
        .executableTarget(
            name: "HeadphoneIssueService",
            dependencies: [],
            path: "Sources"
        )
    ]
)

