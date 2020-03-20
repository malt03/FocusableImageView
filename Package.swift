// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SelectableImageView",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(name: "SelectableImageView", targets: ["SelectableImageView"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "SelectableImageView", dependencies: []),
    ]
)
