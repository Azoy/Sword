# Sword - A Discord Library for Swift

[![Swift Version](https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat-square)](https://swift.org) [![Build Status](https://img.shields.io/travis/Azoy/Sword.svg?&style=flat-square)](https://travis-ci.org/Azoy/Sword) [![Tag](https://img.shields.io/github/tag/Azoy/Sword.svg?style=flat-square&label=release&colorB=)](https://github.com/Azoy/Sword/releases)

# Requirements
1. macOS, Linux, or iOS (no voice for iOS)
2. Swift 3.0
3. libsodium (brew update && brew install libsodium)

# Adding Sword
In order to add Sword as a dependency, you must first create a Swift executable in a designated folder, like so `swift package init --type executable`. Then in the newly created Package.swift, open it and add Sword as a dependency

```swift
import PackageDescription

let package = Package(
    name: "yourswiftexecutablehere",
    dependencies: [
        .Package(url: "https://github.com/Azoy/Sword", majorVersion: 0, minor: 5)
    ]
)
```

After that, open Sources/main.swift and remove everything and replace it with the example below.

```swift
import Sword

let bot = Sword(token: "Your bot token here")

bot.on(.ready) { [unowned bot] _ in
  bot.editStatus(to: "online", playing: "with Sword!")
}

bot.on(.messageCreate) { data in
  let msg = data[0] as! Message
  if msg.content == "!ping" {
    msg.reply(with: "Pong!")
  }
}

bot.connect()
```

# Running the bot
Build the libraries with `swift build`, then type `.build/debug/yourswiftexecutablehere`

# Running the bot in Xcode
To run the bot in Xcode, you first have to compile the libraries with `swift build`. Then to build the xcode project, type `swift package generate-xcodeproj`. Finally, type `open yourswiftexecutablehere.xcodeproj`, look at the top and follow the steps below

![Step 1](images/step1.png)

![Step 2](images/step2.png)

![Step 3](images/step3.png)

Then click the play button!

# Links
[Documentation](http://sword.azoy.gg) - (created with [Jazzy](https://github.com/Realm/Jazzy))

Join the [API Channel](https://discord.gg/q7Zyd2r) to ask questions!
