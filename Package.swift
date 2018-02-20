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
      url: "https://github.com/vapor/engine.git",
      "3.0.0-beta.2" ..< "3.0.0-beta.3"
    )
  ],
  targets: [
    .target(
      name: "Sword",
      dependencies: ["WebSocket"]
    ),
    .testTarget(
      name: "SwordTests",
      dependencies: ["Sword"]
    ),
  ],
  swiftLanguageVersions: [4]
)
