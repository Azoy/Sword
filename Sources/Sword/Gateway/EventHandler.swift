//
//  EventHandler.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
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

    guard let event = Event(rawValue: eventName), !self.sword.options.disabledEvents.contains(event) else {
      return
    }

    switch event {

      /// CHANNEL_CREATE
      case .channelCreate:
        if (data["type"] as! Int) == 1 {
          let dm = DMChannel(self.sword, data)
          self.sword.dms[dm.recipients[0].id] = dm
          self.sword.emit(.channelCreate, with: dm)
        }else {
          let channel = GuildChannel(self.sword, data)
          self.sword.guilds[channel.guild!.id]!.channels[channel.id] = channel
          self.sword.emit(.channelCreate, with: channel)
        }

      /// CHANNEL_DELETE
      case .channelDelete:
        if (data["type"] as! Int) == 1 {
          self.sword.emit(.channelDelete, with: DMChannel(self.sword, data))
        }else {
          let channel = GuildChannel(self.sword, data)
          self.sword.guilds[channel.guild!.id]!.channels.removeValue(forKey: channel.id)
          self.sword.emit(.channelDelete, with: channel)
        }

      /// CHANNEL_UPDATE
      case .channelUpdate:
        self.sword.emit(.channelUpdate, with: GuildChannel(self.sword, data))

      /// GUILD_BAN_ADD
      case .guildBanAdd:
        self.sword.emit(.guildBanAdd, with: self.sword.guilds[data["guild_id"] as! String]!, User(self.sword, data["user"] as! [String: Any]))

      /// GUILD_BAN_REMOVE
      case .guildBanRemove:
        self.sword.emit(.guildBanRemove, with: self.sword.guilds[data["guild_id"] as! String]!, User(self.sword, data["user"] as! [String: Any]))

      /// GUILD_CREATE
      case .guildCreate:
        let guildId = data["id"] as! String
        let guild = Guild(self.sword, data, self.id)
        self.sword.guilds[guildId] = guild

        if self.sword.unavailableGuilds[guildId] != nil {
          self.sword.unavailableGuilds.removeValue(forKey: guildId)
          self.sword.emit(.guildAvailable, with: guild)
        }else {
          self.sword.emit(.guildCreate, with: guild)
        }

        if self.sword.options.willCacheAllMembers && guild.members.count != guild.memberCount {
          self.requestOfflineMembers(for: guild.id)
        }

      /// GUILD_DELETE
      case .guildDelete:
        let guild = self.sword.guilds[data["id"] as! String]!

        if data["unavailable"] != nil {
          let unavailableGuild = UnavailableGuild(data, self.id)
          self.sword.unavailableGuilds[guild.id] = unavailableGuild
          self.sword.emit(.guildUnavailable, with: unavailableGuild)
        }else {
          self.sword.emit(.guildDelete, with: guild)
        }

        self.sword.guilds.removeValue(forKey: guild.id)

      /// GUILD_EMOJIS_UPDATE
      case .guildEmojisUpdate:
        var emitEmojis: [Emoji] = []
        let emojis = data["emojis"] as! [[String: Any]]
        for emoji in emojis {
          emitEmojis.append(Emoji(emoji))
        }
        self.sword.emit(.guildEmojisUpdate, with: self.sword.guilds[data["guild_id"] as! String]!, emitEmojis)

      /// GUILD_INTEGRATIONS_UPDATE
      case .guildIntegrationsUpdate:
        self.sword.emit(.guildIntegrationsUpdate, with: self.sword.guilds[data["guild_id"] as! String]!)

      /// GUILD_MEMBER_ADD
      case .guildMemberAdd:
        let guild = self.sword.guilds[data["guild_id"] as! String]!
        let member = Member(self.sword, guild, data)
        guild.members[member.user.id] = member
        self.sword.emit(.guildMemberAdd, with: guild, member)

      /// GUILD_MEMBER_REMOVE
      case .guildMemberRemove:
        let guild = self.sword.guilds[data["guild_id"] as! String]!
        let user = User(self.sword, data["user"] as! [String: Any])
        guild.members.removeValue(forKey: user.id)
        self.sword.emit(.guildMemberRemove, with: guild, user)

      /// GUILD_MEMBERS_CHUNK
      case .guildMembersChunk:
        let guild = self.sword.guilds[data["guild_id"] as! String]!
        let members = data["members"] as! [[String: Any]]
        for member in members {
          let member = Member(self.sword, guild, member)
          guild.members[member.user.id] = member
        }

      /// GUILD_MEMBER_UPDATE
      case .guildMemberUpdate:
        let guild = self.sword.guilds[data["guild_id"] as! String]!
        let member = Member(self.sword, guild, data)
        guild.members[member.user.id] = member
        self.sword.emit(.guildMemberUpdate, with: member)

      /// GUILD_ROLE_CREATE
      case .guildRoleCreate:
        let guild = self.sword.guilds[data["guild_id"] as! String]!
        let role = Role(data["role"] as! [String: Any])
        guild.roles[role.id] = role
        self.sword.emit(.guildRoleCreate, with: guild, role)

      /// GUILD_ROLE_DELETE
      case .guildRoleDelete:
        let guild = self.sword.guilds[data["guild_id"] as! String]!
        let role = guild.roles[data["role_id"] as! String]!
        guild.roles.removeValue(forKey: role.id)
        self.sword.emit(.guildRoleDelete, with: guild, role)

      /// GUILD_ROLE_UPDATE
      case .guildRoleUpdate:
        let guild = self.sword.guilds[data["guild_id"] as! String]!
        let role = Role(data["role"] as! [String: Any])
        guild.roles[role.id] = role
        self.sword.emit(.guildRoleUpdate, with: guild, role)

      /// GUILD_UPDATE
      case .guildUpdate:
        self.sword.emit(.guildUpdate, with: Guild(self.sword, data, self.id))

      /// MESSAGE_CREATE
      case .messageCreate:
        let msg = Message(self.sword, data)
        let guild = self.sword.getGuild(for: msg.channel.id)
        if guild != nil {
          guild!.channels[msg.channel.id]!.messages[msg.id] = msg
        }else {
          if msg.author!.id != self.sword.user!.id {
            self.sword.dms[msg.author!.id]!.messages[msg.id] = msg
          }
        }
        self.sword.emit(.messageCreate, with: msg)

      /// MESSAGE_DELETE
      case .messageDelete:
        let channelId = data["channel_id"] as! String
        let guild = self.sword.getGuild(for: channelId)
        if guild != nil {
          guard let msg = guild!.channels[channelId]!.messages[data["id"] as! String] else {
            self.sword.emit(.messageDelete, with: data["id"] as! String, guild!.channels[channelId]!)
            return
          }
          self.sword.emit(.messageDelete, with: msg, guild!.channels[channelId]!)
        }else {
          guard let msg = self.sword.getDM(for: channelId)!.messages[data["id"] as! String] else {
            self.sword.emit(.messageDelete, with: data["id"] as! String, self.sword.getDM(for: channelId)!)
            return
          }
          self.sword.emit(.messageDelete, with: msg, self.sword.getDM(for: channelId)!)
        }

      /// MESSAGE_BULK_DELETE
      case .messageDeleteBulk:
        var messages: [Any] = []
        let messageIds = data["ids"] as! [String]
        let channelId = data["channel_id"] as! String
        let guild = self.sword.getGuild(for: channelId)
        if guild != nil {
          for messageId in messageIds {
            if guild!.channels[channelId]!.messages[messageId] != nil {
              messages.append(guild!.channels[channelId]!.messages[messageId]!)
            }else {
              messages.append(messageId)
            }
          }
          self.sword.emit(.messageDelete, with: messages, guild!.channels[channelId]!)
        }else {
          let dm = self.sword.getDM(for: channelId)!
          for messageId in messageIds {
            if dm.messages[messageId] != nil {
              messages.append(dm.messages[messageId]!)
            }else {
              messages.append(messageId)
            }
          }
          self.sword.emit(.messageDeleteBulk, with: messages, dm)
        }

      /// MESSAGE_UPDATE
      case .messageUpdate:
        self.sword.emit(.messageUpdate, with: data)

      /// PRESENCE_UPDATE
      case .presenceUpdate:
        let userId = (data["user"] as! [String: Any])["id"] as! String
        let presence = Presence(data)
        if self.sword.guilds[data["guild_id"] as! String]!.members[userId] != nil {
          self.sword.guilds[data["guild_id"] as! String]!.members[userId]!.presence = presence
        }
        self.sword.emit(.presenceUpdate, with: userId, presence)

      /// READY
      case .ready:
        self.sword.readyTimestamp = Date()
        self.sessionId = data["session_id"] as? String

        let guilds = data["guilds"] as! [[String: Any]]
        let dms = data["private_channels"] as! [[String: Any]]

        for guild in guilds {
          self.sword.unavailableGuilds[guild["id"] as! String] = UnavailableGuild(guild, self.id)
        }

        for dm in dms {
          let recipients = dm["recipients"] as! [[String: Any]]
          for recipient in recipients {
            self.sword.dms[recipient["id"] as! String] = DMChannel(self.sword, dm)
          }
        }

        self.sword.shardsReady += 1
        self.sword.emit(.shardReady, with: self.id)

        if self.sword.shardsReady == self.sword.shardCount {
          self.sword.user = User(self.sword, data["user"] as! [String: Any])
          self.sword.emit(.ready, with: self.sword.user!)
        }

      /// TYPING_START
      case .typingStart:
        #if !os(Linux)
        let timestamp = Date(timeIntervalSince1970: data["timestamp"] as! Double)
        #else
        let timestamp = Date(timeIntervalSince1970: Double(data["timestamp"] as! Int))
        #endif
        let channelId = data["channel_id"] as! String
        let guild = self.sword.getGuild(for: channelId)

        if guild != nil {
          self.sword.emit(.typingStart, with: guild!.channels[channelId]!, data["user_id"] as! String, timestamp)
        }else {
          self.sword.emit(.typingStart, with: self.sword.getDM(for: channelId)!, data["user_id"] as! String, timestamp)
        }

      /// USER_UPDATE
      case .userUpdate:
        self.sword.emit(.userUpdate, with: User(self.sword, data))

      /// VOICE_STATE_UPDATE
      case .voiceStateUpdate:
        let guildId = data["guild_id"] as! String
        let channelId = data["channel_id"] as? String
        let sessionId = data["session_id"] as! String
        let userId = data["user_id"] as! String

        if channelId != nil {
          let voiceState = VoiceState(data)

          self.sword.guilds[guildId]!.voiceStates[userId] = voiceState
          self.sword.guilds[guildId]!.members[userId]?.voiceState = voiceState

          self.sword.emit(.voiceChannelJoin, with: userId, voiceState)
        }else {
          self.sword.guilds[guildId]!.voiceStates.removeValue(forKey: userId)
          self.sword.guilds[guildId]!.members[userId]?.voiceState = nil

          self.sword.emit(.voiceChannelLeave, with: userId)
        }

        self.sword.emit(.voiceStateUpdate, with: userId)

        guard userId == self.sword.user!.id else { return }

        if channelId != nil {
          self.sword.voiceManager.guilds[guildId] = ["channelId": channelId!, "sessionId": sessionId, "userId": userId]
        }else {
          self.sword.voiceManager.leave(guildId)
        }

      /// VOICE_SERVER_UPDATE
      case .voiceServerUpdate:
        let guildId = data["guild_id"] as! String
        let token = data["token"] as! String
        let endpoint = data["endpoint"] as! String

        guard self.sword.voiceManager.guilds[guildId] != nil else { return }

        let payload = Payload(
          voiceOP: .identify,
          data: [
            "server_id": guildId,
            "user_id": self.sword.user!.id,
            "session_id": self.sword.voiceManager.guilds[guildId]!["sessionId"],
            "token": token
          ]
        ).encode()

        self.sword.voiceManager.join(guildId, endpoint, payload)

      default:
        break
    }
  }

}
