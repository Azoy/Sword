import Foundation

extension Shard {

  func handleEvents(_ payload: Payload, _ eventName: String) {
    let data = payload.d as! [String: Any]

    switch Event(rawValue: eventName)! {
      case .guildCreate:
        let guildId = data["id"] as! String

        if self.sword.unavailableGuilds[guildId] != nil {
          self.sword.unavailableGuilds.removeValue(forKey: guildId)

          let guild = Guild(self.sword, data, self.id)
          self.sword.guilds[guildId] = guild
          self.sword.emit("guildAvailable", with: guild)
        }else {
          let guild = Guild(self.sword, data, self.id)
          self.sword.guilds[guildId] = guild
          self.sword.emit("guildCreate", with: guild)
        }

        break
      case .ready:
        self.sessionId = data["session_id"] as? String

        let guilds = data["guilds"] as! [[String: Any]]

        for guild in guilds {
          self.sword.unavailableGuilds[guild["id"] as! String] = UnavailableGuild(guild, self.id)
        }

        self.sword.user = User(self.sword, data["user"] as! [String: Any])
        self.sword.emit("ready", with: self.sword.user!)
        break
      case .presenceUpdate:
        let user = User(self.sword, data["user"] as! [String: Any])
        self.sword.emit("presenceUpdate", with: user.id, ["status": data["status"] as! String, "game": data["game"]])
        break
      default:
        print(eventName)
    }
  }

}
