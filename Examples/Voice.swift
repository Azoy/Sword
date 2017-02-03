import Sword

let bot = Sword(token: "Super secret token here")

bot.register("join") { msg, args in
  guard msg.member?.voiceState != nil else {
    msg.reply(with: "User is not in voice channel.")

    return
  }

  bot.join(voiceChannel: msg.member!.voiceState!.channelId) { connection in
    connection.play(Youtube("https://www.youtube.com/watch?v=dQw4w9WgXcQ"))
  }
}

bot.register("leave") { msg, args in
  guard msg.member?.voiceState != nil else {
    msg.reply(with: "User is not in voice channel.")

    return
  }

  bot.leave(voiceChannel: msg.member!.voiceState!.channelId)
}
