// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SRswift",
    platforms: [
        .macOS(.v12), .iOS(.v13), .visionOS(.v2)
    ],
    products: [
        .library(name: "SRswift", targets: ["SRswift"])
    ],
    dependencies: [],
    targets: [
        .target(name: "SRswift"),
        .testTarget(
            name: "SRswiftTests",
            dependencies: ["SRswift"]
        )
    ]
)

