// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BoxNetworking",
    products: [
        .library(
            name: "BoxNetworking",
            targets: ["BoxNetworking"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket", from: "7.6.4")
    ],
    targets: [
        .target(
            name: "BoxNetworking",
            dependencies: ["CocoaAsyncSocket"]),
        .testTarget(
            name: "BoxNetworkingTests",
            dependencies: ["BoxNetworking"]),
    ]
)
