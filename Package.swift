// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scout",
    platforms: [.macOS("10.13"), .iOS("10.0"), .tvOS("10.0"), .watchOS("4.0")],
    products: [
        .library(
            name: "Scout",
            targets: ["Scout"]),
        .library(
            name: "Parsing",
            targets: ["Parsing"]),
        .library(
            name: "ScoutCLTCore",
            targets: ["ScoutCLTCore"]),
        .executable(
            name: "ScoutCLT",
            targets: ["ScoutCLT"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/tadija/AEXML.git",
            from: "4.5.0"),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "0.0.1"),
        .package(
            url: "https://github.com/ABridoux/lux",
            from: "0.1.0"),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            from: "4.0.0"),
        .package(
            url: "https://github.com/swiftcsv/SwiftCSV",
            from: "0.6.0"),
        .package(
            url: "https://github.com/ABridoux/BooleanExpressionEvaluation",
            from: "2.0.0"),
        .package(
            url: "https://github.com/apple/swift-docc-plugin",
            from: "1.0.0"
        )
    ],
    targets: [
        .target(
            name: "Scout",
            dependencies: [
                "AEXML",
                "Yams",
                "SwiftCSV",
                "Parsing",
                "BooleanExpressionEvaluation"
            ]
        ),
        .target(name: "Parsing"),
        .target(
            name: "ScoutCLTCore",
            dependencies: [
                "Scout",
                "Parsing"
            ]
        ),
        .executableTarget(
            name: "ScoutCLT",
            dependencies: [
                "Scout",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Lux", package: "Lux"),
                "ScoutCLTCore"
            ]
        ),
        .testTarget(
            name: "ScoutTests",
            dependencies: ["Scout"]),
        .testTarget(
            name: "ScoutCLTCoreTests",
            dependencies: [
                "ScoutCLTCore",
                "Scout",
                "Parsing"
            ]
        )
    ]
)
