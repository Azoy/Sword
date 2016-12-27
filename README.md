# Sword - A Discord Library for Swift

# Requirements
1. macOS (Linux and iOS soon!)
2. Swift 3.0
3. An internet connection

# Adding Sword
In order to add Sword as a dependency, you must first create a Swift executable in a designated folder, like so `swift package init --type executable`. Then in the newly created Package.swift, open it and add Sword as a dependency

```swift
import PackageDescription

let package = Package(
    name: "yourswiftexecutablehere",
    dependencies: [
        .Package(url: "https://github.com/Azoy/Sword", majorVersion: 0, minor: 1)
    ]
)
```

After that, open Sources/main.swift and remove everything and replace it with the example below.

```swift
import Sword

let bot = Sword(token: "Your bot token here")

bot.on("ready") { _ in
  bot.editStatus(playing: ["name": "with Swords!"])
}

bot.on("messageCreate") { data in
  let msg = data[0] as! Message
  if msg.content == "!ping" {
    bot.send("Pong!", to: msg.channel.id)
  }
}

bot.connect()
```

# Links
https://azoy.github.io/Sword - Docs (created with https://github.com/Realm/Jazzy)

https://github.com/Azoy/Sword/wiki - For more information on Installation and Events
