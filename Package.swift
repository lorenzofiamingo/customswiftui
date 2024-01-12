// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "customswiftui",
    products: [
        .library(
            name: "CustomSwiftUI",
            targets: ["CustomSwiftUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-format", from: "509.0.0")
    ],
    targets: [
        .target(
            name: "CustomSwiftUI",
            dependencies: []
        )
    ]
)
