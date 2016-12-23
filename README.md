# Sword
A Swift Package for the Discord API - **This is very early in development**

## Install
In order to include Sword as a dependency, you need to have macOS (Linux soon), Swift 3.0, and an internet connection
```swift
let package = Package(
    name: "yourswiftexecutablenamehere",
    dependencies: [
        .Package(url: "https://github.com/Azoy/Sword", Version(0, 1, 0))
    ]
)
```

## Example
```swift
import Sword

let bot = Sword(token: "tokenhere")

bot.on("messageCreate") { msg in
  let msg = msg[0] as! Message
  if msg.content == "!ping" {
    bot.send("Pong!", to: msg.channel.id)
  }

  if msg.content == "!bird" {
    let content = ["file": "http://wallpapercave.com/wp/itSvDL2.jpg", "content": "Little birdy!"]
    bot.send(content, to msg.channel.id)
  }
}

bot.connect()
```
