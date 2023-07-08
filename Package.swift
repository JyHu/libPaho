// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "libPahoC",
    products: [
        .library(
            name: "libPahoC",
            targets: ["libPahoC"]
        ),
        .library(
            name: "libssl",
            targets: ["libssl"]
        ),
        .library(
            name: "CocoaPaho",
            targets: ["CocoaPaho"]
        )
    ],
    dependencies: [ ],
    targets: [
        .target(
            name: "libPahoC",
            dependencies: ["libssl"],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include")
            ]
        ),
        .target(
            name: "libssl",
            dependencies: [],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include")
            ]
        ),
        .target(
            name: "CocoaPaho",
            dependencies: ["libPahoC"],
            cSettings: [
                .headerSearchPath("include")
            ]
        ),
        .testTarget(
            name: "libPahoCTests",
            dependencies: ["libPahoC"]
        ),
        .testTarget(
            name: "CocoaPahoTests",
            dependencies: ["CocoaPaho"]
        ),
    ]
)
