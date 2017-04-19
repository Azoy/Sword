// swift-tools-version:3.1

import PackageDescription

#if os(macOS)
let dependencies: [Package.Dependency] = [
  .Package(
    url: "https://github.com/Azoy/Sodium",
    majorVersion: 1
  )
]
#else
let dependencies: [Package.Dependency] = [
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
  dependencies: [
    .Package(
      url: "https://github.com/vapor/engine",
      majorVersion: 1,
      minor: 3
    )
  ],
  swiftLanguageVersions: [3],
  exclude: ["Examples", "docs"]
)

package.dependencies += dependencies
