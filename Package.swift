// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MijickPopupView",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16)
    ],
    products: [
        .library(name: "MijickPopupView", targets: ["MijickPopupView"])
    ],
    targets: [
        .target(name: "MijickPopupView", dependencies: [], path: "Sources")
    ],
    swiftLanguageVersions: [.version("6")]
)
