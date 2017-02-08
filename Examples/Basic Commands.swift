import Sword

let options = ShieldOptions()
options.prefixes = ["!"]

let bot = Shield(token: "Super secret token here", shieldOptions: options)

bot.register("ping", "Pong!")

bot.register("echo") { msg, args in
  msg.reply(with: args.joined(separator: " "))
}

bot.connect()
