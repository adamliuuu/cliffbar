// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FrugalEra",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FrugalEra",
            targets: ["FrugalEra"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FrugalEra",
            dependencies: []),
        .testTarget(
            name: "FrugalEraTests",
            dependencies: ["FrugalEra"]),
    ]
) 