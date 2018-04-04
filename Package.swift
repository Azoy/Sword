// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "Sword",
  products: [
    .library(
      name: "Sword",
      targets: ["Sword"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/Azoy/Starscream.git",
      from: "3.0.5"
    )
  ],
  targets: [
    .target(
      name: "Sword",
      dependencies: ["Starscream"]
    ),
    .testTarget(
      name: "SwordTests",
      dependencies: ["Sword"]
    ),
  ],
  swiftLanguageVersions: [4]
)
