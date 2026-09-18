// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ForgeFit",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [.library(name: "ForgeFitCore", targets: ["ForgeFitCore"]), .executable(name: "ForgeFitApp", targets: ["ForgeFitApp"])],
    targets: [
        .target(name: "ForgeFitCore", path: "Sources/ForgeFitCore"),
        .executableTarget(name: "ForgeFitApp", dependencies: ["ForgeFitCore"], path: "Sources/ForgeFitApp"),
        .testTarget(name: "ForgeFitTests", dependencies: ["ForgeFitCore"], path: "Tests/ForgeFitTests")
    ]
)
