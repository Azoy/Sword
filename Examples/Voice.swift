import Sword

let bot = Shield(token: "Super secret token here")

bot.register("join") { [unowned bot] msg, args in
  guard let voiceState = msg.member?.voiceState else {
    msg.reply(with: "User is not in voice channel.")

    return
  }

  bot.joinVoiceChannel(voiceState.channelId) { connection in
    connection.play(Youtube("https://www.youtube.com/watch?v=dQw4w9WgXcQ"))
  }
}

bot.register("leave") { [unowned bot] msg, args in
  guard let voiceState = msg.member?.voiceState else {
    msg.reply(with: "User is not in voice channel.")

    return
  }

  bot.leaveVoiceChannel(voiceState.channelId)
}

bot.connect()
