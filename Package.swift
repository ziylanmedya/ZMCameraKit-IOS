// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ZMCKit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "ZMCKit",
            targets: ["ZMCKit"]),
    ],
    targets: [
        .target(
            name: "ZMCKit",
            dependencies: [
                "SCSDKCameraKitReferenceUI",
                "SCSDKCameraKit",
                "SCSDKCoreKit",
                "SCSDKCreativeKit"
            ],
            path: "Sources/ZMCKit"
        ),
        .testTarget(
            name: "ZMCKitTests",
            dependencies: ["ZMCKit"]
        ),
        .binaryTarget(
            name: "SCSDKCameraKitReferenceUI",
            path: "./XCFrameworks/SCSDKCameraKitReferenceUI.xcframework"
        ),
        .binaryTarget(
            name: "SCSDKCameraKit",
            path: "./XCFrameworks/SCSDKCameraKit.xcframework"
        ),
        .binaryTarget(
            name: "SCSDKCoreKit",
            path: "./XCFrameworks/SCSDKCoreKit.xcframework"
        ),
        .binaryTarget(
            name: "SCSDKCreativeKit",
            path: "./XCFrameworks/SCSDKCreativeKit.xcframework"
        ),
    ]
)
