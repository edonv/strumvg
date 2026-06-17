// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "strumvg",
    platforms: [
        .macOS(.v15),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.8.2"),
        .package(url: "https://github.com/JohnSundell/Plot.git", from: "0.14.0"),
        .package(url: "https://github.com/edonv/PlotSVG.git", exact: "0.0.0"),
        .package(
            url: "https://github.com/apple/swift-configuration.git",
            from: "1.2.0",
            traits: [.defaults, "Logging", "YAML", "CommandLineArguments"]
        ),
    ],
    targets: [
        .target(name: "StrumModels"),
        .target(
            name: "PlotExtensions",
            dependencies: [
                .product(name: "Plot", package: "Plot"),
            ]
        ),
        .target(
            name: "StrumVGConfig",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Configuration", package: "swift-configuration"),
            ]
        ),
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "strumvg",
            dependencies: [
                "StrumVGConfig",
                "StrumModels",
                "PlotExtensions",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Configuration", package: "swift-configuration"),
                "Plot",
                "PlotSVG",
            ]
        ),
    ]
)
