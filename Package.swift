// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcbox",
    platforms: [.macOS(.v10_11)],
    products: [
        .library(name: "XCBoxApp", targets: ["XCBoxApp"]),
        .executable(name: "xcbox", targets: ["xcbox"])
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/xcodeproj.git", from: "6.7.0"),
        .package(url: "https://github.com/omochi/FineJSON.git", from: "1.10.0")
    ],
    targets: [
        .target(name: "XCBoxApp", dependencies: [
            "xcodeproj",
            "FineJSON"]),
        .target(name: "xcbox", dependencies: ["XCBoxApp"])
    ]
)
