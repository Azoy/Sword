import Sword

var options = ShieldOptions()
options.prefixes = ["!"]

let bot = Shield(token: "Super secret token here", and: options)

bot.register("ping", message: "Pong!")

bot.register("echo") { msg, args in
  msg.reply(with: args.joined(separator: " "))
}

bot.connect()
