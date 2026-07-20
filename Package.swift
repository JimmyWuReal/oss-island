// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "OssIsland",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "OssIslandCore", targets: ["OssIslandCore"]),
        .executable(name: "OssIsland", targets: ["OssIsland"]),
        .executable(name: "oss-island-event", targets: ["OssIslandEventCLI"]),
        .executable(name: "OssIslandCoreChecks", targets: ["OssIslandCoreChecks"])
    ],
    targets: [
        .target(name: "OssIslandCore"),
        .executableTarget(
            name: "OssIsland",
            dependencies: ["OssIslandCore"]
        ),
        .executableTarget(
            name: "OssIslandEventCLI",
            dependencies: ["OssIslandCore"]
        ),
        .executableTarget(
            name: "OssIslandCoreChecks",
            dependencies: ["OssIslandCore"]
        )
    ]
)
