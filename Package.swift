// swift-tools-version:3.1

import PackageDescription

#if os(iOS)
let dependencies: [Package.Dependency] = [
  .Package(
    url: "https://github.com/daltoniam/Starscream",
    majorVersion: 2
  )
]
#else
var dependencies: [Package.Dependency] = [
  .Package(
    url: "https://github.com/vapor/engine",
    majorVersion: 2
  )
]
#endif

#if os(macOS)
dependencies.append(
  .Package(
    url: "https://github.com/Azoy/Sodium",
    majorVersion: 1
  )
)
#elseif os(Linux)
dependencies.append(
  .Package(
    url: "https://github.com/Azoy/Sodium-Linux",
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
