// swift-tools-version:3.1

import PackageDescription

#if !os(Linux)
var dependencies: [Package.Dependency] = [
  .Package(
    url: "https://github.com/daltoniam/Starscream",
    majorVersion: 2
  )
]
#else
let dependencies: [Package.Dependency] = [
  .Package(
    url: "https://github.com/vapor/engine",
    majorVersion: 2
  ),
  .Package(
    url: "https://github.com/Azoy/Sodium-Linux",
    majorVersion: 1
  )
]
#endif

#if os(macOS)
dependencies += [
  .Package(
    url: "https://github.com/Azoy/Sodium",
    majorVersion: 1
  ),
  .Package(
    url: "https://github.com/vapor/sockets",
    majorVersion: 2
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
  exclude: ["Examples", "docs", "images"]
)
