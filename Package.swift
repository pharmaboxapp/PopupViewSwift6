// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swift6PopupView",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16)
    ],
    products: [
        .library(name: "Swift6PopupView", targets: ["Swift6PopupView"])
    ],
    targets: [
        .target(name: "Swift6PopupView", dependencies: [], path: "Sources")
    ],
    swiftLanguageVersions: [.version("6")]
)
