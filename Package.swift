// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scout",
    platforms: [.macOS("10.13"), .iOS("10.0"), .tvOS("9.0"), .watchOS("3.0")],
    products: [
        .library(
            name: "Scout",
            targets: ["Scout"]),
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
            from: "4.0.0")
    ],
    targets: [
        .target(
            name: "Scout",
            dependencies: ["AEXML", "Yams"]),
        .target(
            name: "ScoutCLTCore",
            dependencies: ["Scout"]),
        .target(
            name: "ScoutCLT",
            dependencies: ["Scout", "ArgumentParser", "Lux", "ScoutCLTCore"]),
        .testTarget(
            name: "ScoutTests",
            dependencies: ["Scout"]),
        .testTarget(
            name: "ScoutCLTCoreTests",
            dependencies: ["ScoutCLTCore", "Scout"])
    ]
)
