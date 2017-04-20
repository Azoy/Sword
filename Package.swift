// swift-tools-version:3.1

import PackageDescription

#if os(macOS)
let dependencies: [Package.Dependency] = [
  .Package(
    url: "https://github.com/daltoniam/Starscream",
    majorVersion: 2
  ),
  .Package(
    url: "https://github.com/Azoy/Sodium",
    majorVersion: 1
  ),
  .Package(
    url: "https://github.com/vapor/sockets",
    majorVersion: 1,
    minor: 2
  )
]
#else
let dependencies: [Package.Dependency] = [
  .Package(
    url: "https://github.com/vapor/engine",
    majorVersion: 1
  ),
  .Package(
    url: "https://github.com/Azoy/Sodium-Linux",
    majorVersion: 1
  )
]
#endif

let package = Package(
  name: "Sword",
  targets: [
    Target(
      name: "Sword",
      dependencies: []
    )
  ],
  dependencies: dependencies,
  swiftLanguageVersions: [3],
  exclude: ["Examples", "docs"]
)
