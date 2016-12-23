import Foundation

extension Shard {

  func handleEvents(_ payload: Payload, _ eventName: String) {
    let data = payload.d as! [String: Any]

    switch Event(rawValue: eventName)! {
      case .channelCreate:
        if (data["is_private"] as! Bool) {
          self.sword.emit("channelCreate", with: DMChannel(self.sword, data))
        }else {
          let channel = Channel(self.sword, data)
          self.sword.guilds[channel.guildId!]!.channels[channel.id] = channel
          self.sword.emit("channelCreate", with: channel)
        }
        break
      case .channelDelete:
        if (data["is_private"] as! Bool) {
          self.sword.emit("channelDelete", with: DMChannel(self.sword, data))
        }else {
          let channel = Channel(self.sword, data)
          self.sword.guilds[channel.guildId!]!.channels.removeValue(forKey: channel.id)
          self.sword.emit("channelDelete", with: channel)
        }
        break
      case .channelUpdate:
        self.sword.emit("channelUpdate", with: Channel(self.sword, data))
        break
      case .guildBanAdd:
        self.emit("guildBanAdd", with: data["guild_id"] as! String, User(data))
        break
      case .guildBanRemove:
        self.emit("guildBanRemove", with: data["guild_id"] as! String, User(data))
        break
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
      case .guildDelete:
        let guildId = data["id"] as! String

        self.sword.guilds.removeValue(forKey: guildId)

        if (data["unavailable"] as! Bool) {
          let unavailableGuild = UnavailableGuild(data, self.id)
          self.sword.unavailableGuilds[guildId] = unavailableGuild
          self.sword.emit("guildUnavilable", with: unavailableGuild)
        }else {
          self.sword.emit("guildDelete", with: guildId)
        }
        break
      case .guildEmojisUpdate:
        var emitEmojis: [Emoji] = []
        let emojis = data["emojis"] as! [[String: Any]]
        for emoji in emojis {
          emitEmojis.append(Emoji(emoji))
        }
        self.sword.emit("guildEmojisUpdate", with: data["guild_id"] as! String, emitEmojis)
        break
      case .guildIntegrationsUpdate:
        self.sword.emit("guildIntegrationsUpdate", with: data["guild_id"] as! String)
        break
      case .guildMemberAdd:
        let guildId = data["guild_id"] as! String
        let member = Member(self.sword, data)
        self.sword.guilds[guildId]!.members[member.id] = member
        self.sword.emit("guildMemberAdd", with: guildId, member)
        break
      case .guildMemberRemove:
        let guildId = data["guild_id"] as! String
        let user = User(self.sword, data)
        self.guilds[guildId]!.members.removeValue(forKey: user.id)
        self.sword.emit("guildMemberRemove", with: guildId, user)
        break
      case .guildMemberUpdate:
        let member = Member(self.sword, data)
        self.sword.guilds[guildId]!.members[member.id] = member
        self.sword.emit("guildMemberUpdate", with: member)
        break
      case .guildRoleCreate:
        let guildId = data["guildId"] as! String
        let role = Role(data["role"] as! [String: Any])
        self.sword.guilds[guildId]!.roles[role.id] = role
        self.sword.emit("guildRoleCreate", with: guildId, role)
        break
      case .guildRoleDelete:
        let guildId = data["guild_id"] as! String
        let roleId = data["role_id"] as! String
        self.sword.guilds[guildId]!.roles.removeValue(forKey: roleId)
        self.sword.emit("guildRoleDelete", with: guildId, roleId)
        break
      case .guildRoleUpdate:
        let guildId = data["guild_id"] as! String
        let role = Role(data["role"] as! [String: Any])
        self.sword.guilds[guildId]!.roles[role.id] = role
        self.sword.emit("guildRoleUpdate", with: guildId, role)
        break
      case .guildUpdate:
        self.sword.emit("guildUpdate", with: Guild(self.sword, data, self.id))
        break
      case .messageCreate:
        self.sword.emit("messageCreate", with: Message(self.sword, data))
        break
      case .messageDelete:
        self.sword.emit("messageDelete", with: ["id": data["id"] as! String, "channelId": data["channel_id"] as! String])
        break
      case .messageDeleteBulk:
        let messages = data["ids"] as! [String]
        self.sword.emit("bulkDeleteMessages", with: messages, data["channel_id"] as! String)
        break
      case .messageUpdate:
        self.sword.emit("messageUpdate", with: ["id": data["id"] as! String, "channelId": data["channel_id"] as! String])
        break
      case .presenceUpdate:
        let user = User(self.sword, data["user"] as! [String: Any])
        self.sword.emit("presenceUpdate", with: user.id, ["status": data["status"] as! String, "game": data["game"]])
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
      case .typingStart:
        let timestamp = (data["timestamp"] as! String).date
        self.sword.emit("typingStart", with: data["channel_id"] as! String, data["user_id"] as! String, timestamp)
        break
      case .userUpdate:
        self.sword.emit("userUpdate", with: User(data))
        break
      default:
        break
    }
  }

}
