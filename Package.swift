// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "CustomSwiftUI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "CustomSwiftUI",
            targets: ["CustomSwiftUI"]),
    ],
    targets: [
        .target(
            name: "CustomSwiftUI",
            dependencies: []
        )
    ]
)
