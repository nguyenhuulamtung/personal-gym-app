// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ForgeFit",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [
        .library(name: "ForgeFitCore", targets: ["ForgeFitCore"])
    ],
    targets: [
        .target(name: "ForgeFitCore", path: "Sources/ForgeFitCore"),
        .testTarget(name: "ForgeFitTests", dependencies: ["ForgeFitCore"], path: "Tests/ForgeFitTests")
    ]
)
