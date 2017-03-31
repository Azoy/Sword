import PackageDescription

let package = Package(
  name: "Sword",
  dependencies: [
    .Package(
      url: "https://github.com/vapor/engine", majorVersion: 1
    ),
    .Package(
      url: "https://github.com/Azoy/Sodium", majorVersion: 1
    ),
    .Package(
      url: "https://github.com/Azoy/Sodium-Linux", majorVersion: 1
    )
  ]
)
