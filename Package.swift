// swift-tools-version:4.0

import PackageDescription

var dependencies: [Package.Dependency] = [
  .Package(
    url: "https://github.com/Azoy/Sodium",
    majorVersion: 1
  )
]

#if !os(Linux)
dependencies += [
  .Package(
    url: "https://github.com/daltoniam/Starscream.git",
    majorVersion: 2
  ),
  .Package(
    url: "https://github.com/vapor/sockets.git",
    majorVersion: 2
  )
]
#else
dependencies += [
  .Package(
    url: "https://github.com/vapor/engine.git",
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
