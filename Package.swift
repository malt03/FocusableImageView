// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FocusableImageView",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(name: "FocusableImageView", targets: ["FocusableImageView"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "FocusableImageView", dependencies: []),
    ]
)
