// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Facehash",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "Facehash",
            targets: ["Facehash"]
        ),
    ],
    targets: [
        .target(
            name: "Facehash",
            path: "Sources/Facehash"
        ),
        .testTarget(
            name: "FacehashTests",
            dependencies: ["Facehash"],
            path: "Tests/FacehashTests"
        ),
    ]
)
