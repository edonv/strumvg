// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "strumvg",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/JohnSundell/Plot.git", from: "0.14.0"),
    ],
    targets: [
        .target(name: "StrumModels"),
        .target(
            name: "PlotSVG",
            dependencies: [
                .product(name: "Plot", package: "Plot"),
            ]
        ),
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "strumvg",
            dependencies: [
                .product(name: "Plot", package: "Plot"),
                "StrumModels",
                "PlotSVG",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
