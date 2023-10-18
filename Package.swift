// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "customswiftui",
    products: [
        .library(
            name: "CustomSwiftUI",
            targets: ["CustomSwiftUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/wickwirew/Runtime.git", branch: "master")
    ],
    targets: [
        .target(
            name: "CustomSwiftUI",
            dependencies: ["Runtime"]
        )
    ]
)
