// swift-tools-version:4.0

import PackageDescription

var dependencies: [Package.Dependency] = []

var targetDeps: [Target.Dependency] = []

#if !os(Linux)
dependencies += [
  .package(
    url: "https://github.com/Azoy/Starscream.git",
    .upToNextMajor(from: "3.0.0")
  )
]
  
targetDeps += ["Starscream"]
#else
dependencies += [
  .package(
    url: "https://github.com/vapor/engine.git",
    .upToNextMajor(from: "2.0.0")
  )
]
  
targetDeps += ["URI", "WebSockets"]
#endif

let package = Package(
  name: "Sword",
  products: [
    .library(name: "Sword", targets: ["Sword"])
  ],
  dependencies: dependencies,
  targets: [
    .target(
      name: "Sword",
      dependencies: targetDeps
    )
  ]
)
