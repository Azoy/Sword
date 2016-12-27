//
//  EventHandler.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2016 Alejandro Alonso. All rights reserved.
//

import Foundation

/// EventHandler
extension Shard {

  /**
   Handles all dispatch events

   - parameter data: Data sent with dispatch
   - parameter eventName: Event name sent with dispatch
   */
  func handleEvents(_ data: [String: Any], _ eventName: String) {

    switch eventName {

      /// CHANNEL_CREATE
      case "CHANNEL_CREATE":
        if (data["is_private"] as! Bool) {
          self.sword.emit("channelCreate", with: DMChannel(self.sword, data))
        }else {
          let channel = Channel(self.sword, data)
          self.sword.guilds[channel.guildId!]!.channels[channel.id] = channel
          self.sword.emit("channelCreate", with: channel)
        }
        break

      /// CHANNEL_DELETE
      case "CHANNEL_DELETE":
        if (data["is_private"] as! Bool) {
          self.sword.emit("channelDelete", with: DMChannel(self.sword, data))
        }else {
          let channel = Channel(self.sword, data)
          self.sword.guilds[channel.guildId!]!.channels.removeValue(forKey: channel.id)
          self.sword.emit("channelDelete", with: channel)
        }
        break

      /// CHANNEL_UPDATE
      case "CHANNEL_UPDATE":
        self.sword.emit("channelUpdate", with: Channel(self.sword, data))
        break

      /// GUILD_BAN_ADD
      case "GUILD_BAN_ADD":
        self.sword.emit("guildBanAdd", with: data["guild_id"] as! String, User(self.sword, data))
        break

      /// GUILD_BAN_REMOVE
      case "GUILD_BAN_REMOVE":
        self.sword.emit("guildBanRemove", with: data["guild_id"] as! String, User(self.sword, data))
        break

      /// GUILD_CREATE
      case "GUILD_CREATE":
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

      /// GUILD_DELETE
      case "GUILD_DELETE":
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

      /// GUILD_EMOJIS_UPDATE
      case "GUILD_EMOJIS_UPDATE":
        var emitEmojis: [Emoji] = []
        let emojis = data["emojis"] as! [[String: Any]]
        for emoji in emojis {
          emitEmojis.append(Emoji(emoji))
        }
        self.sword.emit("guildEmojisUpdate", with: data["guild_id"] as! String, emitEmojis)
        break

      /// GUILD_INTEGRATIONS_UPDATE
      case "GUILD_INTEGRATIONS_UPDATE":
        self.sword.emit("guildIntegrationsUpdate", with: data["guild_id"] as! String)
        break

      /// GUILD_MEMBER_ADD
      case "GUILD_MEMBER_ADD":
        let guildId = data["guild_id"] as! String
        let member = Member(self.sword, data)
        self.sword.guilds[guildId]!.members[member.user.id] = member
        self.sword.emit("guildMemberAdd", with: guildId, member)
        break

      /// GUILD_MEMBER_REMOVE
      case "GUILD_MEMBER_REMOVE":
        let guildId = data["guild_id"] as! String
        let user = User(self.sword, data)
        self.sword.guilds[guildId]!.members.removeValue(forKey: user.id)
        self.sword.emit("guildMemberRemove", with: guildId, user)
        break

      /// GUILD_MEMBER_UPDATE
      case "GUILD_MEMBER_UPDATE":
        let guildId = data["guild_id"] as! String
        let member = Member(self.sword, data)
        self.sword.guilds[guildId]!.members[member.user.id] = member
        self.sword.emit("guildMemberUpdate", with: member)
        break

      /// GUILD_ROLE_CREATE
      case "GUILD_ROLE_CREATE":
        let guildId = data["guildId"] as! String
        let role = Role(data["role"] as! [String: Any])
        self.sword.guilds[guildId]!.roles[role.id] = role
        self.sword.emit("guildRoleCreate", with: guildId, role)
        break

      /// GUILD_ROLE_DELETE
      case "GUILD_ROLE_DELETE":
        let guildId = data["guild_id"] as! String
        let roleId = data["role_id"] as! String
        self.sword.guilds[guildId]!.roles.removeValue(forKey: roleId)
        self.sword.emit("guildRoleDelete", with: guildId, roleId)
        break

      /// GUILD_ROLE_UPDATE
      case "GUILD_ROLE_UPDATE":
        let guildId = data["guild_id"] as! String
        let role = Role(data["role"] as! [String: Any])
        self.sword.guilds[guildId]!.roles[role.id] = role
        self.sword.emit("guildRoleUpdate", with: guildId, role)
        break

      /// GUILD_UPDATE
      case "GUILD_UPDATE":
        self.sword.emit("guildUpdate", with: Guild(self.sword, data, self.id))
        break

      /// MESSAGE_CREATE
      case "MESSAGE_CREATE":
        self.sword.emit("messageCreate", with: Message(self.sword, data))
        break

      /// MESSAGE_DELETE
      case "MESSAGE_DELETE":
        self.sword.emit("messageDelete", with: data["id"] as! String, data["channel_id"] as! String)
        break

      /// MESSAGE_BULK_DELETE
      case "MESSAGE_BULK_DELETE":
        let messages = data["ids"] as! [String]
        self.sword.emit("bulkDeleteMessages", with: messages, data["channel_id"] as! String)
        break

      /// MESSAGE_UPDATE
      case "MESSAGE_UPDATE":
        self.sword.emit("messageUpdate", with: data["id"] as! String, data["channel_id"] as! String)
        break

      /// PRESENCE_UPDATE
      case "PRESENCE_UPDATE":
        let user = User(self.sword, data["user"] as! [String: Any])
        self.sword.emit("presenceUpdate", with: user.id, ["status": data["status"] as! String, "game": data["game"]])
        break

      /// READY
      case "READY":
        self.sessionId = data["session_id"] as? String

        let guilds = data["guilds"] as! [[String: Any]]

        for guild in guilds {
          self.sword.unavailableGuilds[guild["id"] as! String] = UnavailableGuild(guild, self.id)
        }

        self.sword.user = User(self.sword, data["user"] as! [String: Any])
        self.sword.emit("ready", with: self.sword.user!)
        break

      /// TYPING_START
      case "TYPING_START":
        let timestamp = Date(timeIntervalSince1970: data["timestamp"] as! Double)
        self.sword.emit("typingStart", with: data["channel_id"] as! String, data["user_id"] as! String, timestamp)
        break

      /// USER_UPDATE
      case "USER_UPDATE":
        self.sword.emit("userUpdate", with: User(self.sword, data))
        break

      /// Others~~~ (voice)
      default:
        break
    }
  }

}
