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
      url: "https://github.com/vapor/websocket.git",
      from: "1.0.0"
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
