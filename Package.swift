// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "Sword",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .library(
      name: "Sword",
      targets: ["Sword"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/daltoniam/starscream.git",
      .branch("master")
    ),
    .package(
      url: "https://github.com/swift-server/async-http-client.git",
      .branch("master")
    )
  ],
  targets: [
    .target(
      name: "Sword",
      dependencies: [
        "Starscream",
        "AsyncHTTPClient"
      ]
    ),
    .testTarget(
      name: "SwordTests",
      dependencies: ["Sword"]
    ),
  ],
  swiftLanguageVersions: [.version("5.1")]
)
