// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "GameLibrary",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "GameLibrary",
            path: "Sources",
            resources: [
                .copy("Resources/games.json")
            ]
        )
    ]
)
