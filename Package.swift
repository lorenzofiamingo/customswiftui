// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "customswiftui",
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
