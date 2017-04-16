// swift-tools-version:3.1

import PackageDescription

#if os(macOS)
let sodium = Package.Dependency.Package(url: "https://github.com/Azoy/Sodium", majorVersion: 1)
#else
let sodium = Package.Dependency.Package(url: "https://github.com/Azoy/Sodium-Linux", majorVersion: 1)
#endif

let package = Package(
  name: "Sword",
  dependencies: [
    .Package(
      url: "https://github.com/vapor/engine", majorVersion: 1
    )
  ],
  swiftLanguageVersions: [3]
)

package.dependencies.append(sodium)
