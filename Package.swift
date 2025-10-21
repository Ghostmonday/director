// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DirectorStudio",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "DirectorStudio",
            targets: ["DirectorStudio"]
        ),
        .library(
            name: "DirectorStudioUI",
            targets: ["DirectorStudioUI"]
        ),
    ],
    dependencies: [
        // iOS-only dependencies
    ],
    targets: [
        .target(
            name: "DirectorStudio",
            dependencies: [],
            path: "Sources/DirectorStudio"
        ),
        .target(
            name: "DirectorStudioUI",
            dependencies: ["DirectorStudio"],
            path: "Sources/DirectorStudioUI"
        ),
        .testTarget(
            name: "DirectorStudioTests",
            dependencies: ["DirectorStudio"],
            path: "Tests/DirectorStudioTests"
        ),
    ]
)
