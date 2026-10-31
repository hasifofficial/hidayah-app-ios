// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Shimmer",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "Shimmer",
            targets: ["Shimmer"]
        )
    ],
    targets: [
        .target(
            name: "Shimmer",
            path: "Sources/Shimmer",
            publicHeadersPath: "include"
        )
    ]
)
