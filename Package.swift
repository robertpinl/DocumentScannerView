// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DocumentScannerView",
    platforms: [
        .iOS(.v17),
        .macCatalyst(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "DocumentScannerView",
            targets: ["DocumentScannerView"]
        ),
    ],
    targets: [
        .target(
            name: "DocumentScannerView",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "DocumentScannerViewTests",
            dependencies: ["DocumentScannerView"]
        ),
    ]
)
