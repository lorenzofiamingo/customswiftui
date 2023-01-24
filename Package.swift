// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "CustomSwiftUI",
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
