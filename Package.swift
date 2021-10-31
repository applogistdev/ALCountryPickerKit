
// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "ALCountryPickerKit",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "ALCountryPickerKit",
            targets: ["ALCountryPickerKit"]),
    ],
    targets: [
        .target(
            name: "ALCountryPickerKit",
            dependencies: [],
            path: "ALCountryPickerKit")
    ]
)
