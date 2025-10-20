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
        .executable(
            name: "DirectorStudioCLI",
            targets: ["DirectorStudioCLI"]
        ),
        .library(
            name: "DirectorStudioUI",
            targets: ["DirectorStudioUI"]
        ),
    ],
    dependencies: [
        // CLI-compatible dependencies only
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "DirectorStudio",
            dependencies: [],
            path: "Sources/DirectorStudio"
        ),
        .executableTarget(
            name: "DirectorStudioCLI",
            dependencies: [
                "DirectorStudio",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/DirectorStudioCLI"
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
