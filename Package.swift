// swift-tools-version:3.1

import PackageDescription

#if !os(Linux)
var dependencies: [Package.Dependency] = [
  .Package(
    url: "https://github.com/daltoniam/Starscream.git",
    majorVersion: 2,
    minor: 0
  )
]
#else
var dependencies: [Package.Dependency] = [
  .Package(
    url: "https://github.com/vapor/engine.git",
    majorVersion: 2
  )
]
#endif

#if os(macOS)
dependencies += [
  .Package(
    url: "https://github.com/vapor/sockets.git",
    majorVersion: 2
  ),
  .Package(
    url: "https://github.com/Azoy/Sodium.git",
    majorVersion: 1
  )
]
#elseif os(Linux)
dependencies.append(
  .Package(
    url: "https://github.com/Azoy/Sodium-Linux.git",
    majorVersion: 1
  )
)
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
