// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpatialReasoning",
    platforms: [
        .macOS(.v12), .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SpatialReasoning",
            targets: ["SpatialReasoning"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SpatialReasoning"),
        .testTarget(
            name: "SpatialReasoningTests",
            dependencies: ["SpatialReasoning"]
        )
    ]
)
