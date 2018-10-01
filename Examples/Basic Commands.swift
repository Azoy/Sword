import Sword

let options = ShieldOptions(
  prefixes: ["!"]
)

let bot = Shield(token: "Super secret token here", shieldOptions: options)

bot.register("ping", message: "Pong!")

bot.register("echo") { msg, args in
  msg.reply(with: args.joined(separator: " "))
}

bot.connect()
