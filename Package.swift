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
        .executable(
            name: "DirectorStudioApp",
            targets: ["DirectorStudioApp"]
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
        .executableTarget(
            name: "DirectorStudioApp",
            dependencies: ["DirectorStudioUI"],
            path: "Sources/DirectorStudioApp"
        ),
        .testTarget(
            name: "DirectorStudioTests",
            dependencies: ["DirectorStudio"],
            path: "Tests/DirectorStudioTests"
        ),
    ]
)
