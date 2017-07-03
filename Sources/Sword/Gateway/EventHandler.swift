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
  func handleEvent(_ data: [String: Any], _ eventName: String) {

    guard let event = Event(rawValue: eventName) else {
      self.sword.log("Received unknown event: \(eventName)")
      return
    }

    guard !self.sword.options.disabledEvents.contains(event), self.sword.listeners[event] != nil else {
      return
    }

    switch event {

      /// CHANNEL_CREATE
      case .channelCreate:
        switch data["type"] as! Int {
          case 0, 2:
            let channel = GuildChannel(self.sword, data)
            self.sword.guilds[channel.guild!.id]!.channels[channel.id] = channel
            self.sword.emit(.channelCreate, with: channel)

          case 1:
            let dm = DMChannel(self.sword, data)
            self.sword.dms[dm.recipient.id] = dm
            self.sword.emit(.channelCreate, with: dm)

          case 3:
            let group = GroupChannel(self.sword, data)
            self.sword.groups[group.id] = group
            self.sword.emit(.channelCreate, with: group)

          default:
            break
        }

      /// CHANNEL_DELETE
      case .channelDelete:
        switch data["type"] as! Int {
          case 0, 2:
            let channel = self.sword.guilds[GuildID(data["guild_id"] as! String)!]!.channels.removeValue(forKey: ChannelID(data["id"] as! String)!)
            self.sword.emit(.channelDelete, with: channel!)

          case 1:
            let recipient = (data["recipients"] as! [[String: Any]])[0]
            let dm = self.sword.dms.removeValue(forKey: UserID(recipient["id"] as! String)!)
            self.sword.emit(.channelDelete, with: dm!)

          case 3:
            let group = self.sword.groups.removeValue(forKey: ChannelID(data["id"] as! String)!)
            self.sword.emit(.channelDelete, with: group!)

          default:
            break
        }

      /// CHANNEL_UPDATE
      case .channelUpdate:
        switch data["type"] as! Int {
          case 0, 2:
            let channel = GuildChannel(self.sword, data)
            self.sword.guilds[channel.guild!.id]!.channels[channel.id] = channel
            self.sword.emit(.channelUpdate, with: channel)

          case 3:
            let group = GroupChannel(self.sword, data)
            self.sword.groups[group.id] = group
            self.sword.emit(.channelUpdate, with: group)

          default:
            break
        }

      /// GUILD_BAN_ADD & GUILD_BAN_REMOVE
      case .guildBanAdd, .guildBanRemove:
        let guildID = GuildID(data["guild_id"] as! String)!
        let user = User(self.sword, data["user"] as! [String: Any])
        self.sword.emit(event, with: (self.sword.guilds[guildID]!, user))

      /// GUILD_CREATE
      case .guildCreate:
        let guild = Guild(self.sword, data, self.id)
        self.sword.guilds[guild.id] = guild

        if self.sword.unavailableGuilds[guild.id] != nil {
          self.sword.unavailableGuilds.removeValue(forKey: guild.id)
          self.sword.emit(.guildAvailable, with: guild)
        }else {
          self.sword.emit(.guildCreate, with: guild)
        }

        if self.sword.options.willCacheAllMembers && guild.members.count != guild.memberCount {
          self.requestOfflineMembers(for: guild.id)
        }

      /// GUILD_DELETE
      case .guildDelete:
        let guild = self.sword.guilds.removeValue(forKey: GuildID(data["id"] as! String)!)!

        if data["unavailable"] != nil {
          let unavailableGuild = UnavailableGuild(data, self.id)
          self.sword.unavailableGuilds[guild.id] = unavailableGuild
          self.sword.emit(.guildUnavailable, with: unavailableGuild)
        }else {
          self.sword.emit(.guildDelete, with: guild)
        }

      /// GUILD_EMOJIS_UPDATE
      case .guildEmojisUpdate:
        let emojis = (data["emojis"] as! [[String: Any]]).map(Emoji.init)
        let guild = self.sword.guilds[GuildID(data["guild_id"] as! String)!]!
        guild.emojis = emojis
        self.sword.emit(.guildEmojisUpdate, with: (guild, emojis))

      /// GUILD_INTEGRATIONS_UPDATE
      case .guildIntegrationsUpdate:
        self.sword.emit(.guildIntegrationsUpdate, with: self.sword.guilds[GuildID(data["guild_id"] as! String)!]!)

      /// GUILD_MEMBER_ADD
      case .guildMemberAdd:
        let guild = self.sword.guilds[GuildID(data["guild_id"] as! String)!]!
        let member = Member(self.sword, guild, data)
        guild.members[member.user.id] = member
        self.sword.emit(.guildMemberAdd, with: (guild, member))

      /// GUILD_MEMBER_REMOVE
      case .guildMemberRemove:
        let guild = self.sword.guilds[GuildID(data["guild_id"] as! String)!]!
        let user = User(self.sword, data["user"] as! [String: Any])
        guild.members.removeValue(forKey: user.id)
        self.sword.emit(.guildMemberRemove, with: (guild, user))

      /// GUILD_MEMBERS_CHUNK
      case .guildMembersChunk:
        let guild = self.sword.guilds[GuildID(data["guild_id"] as! String)!]!
        let members = data["members"] as! [[String: Any]]
        for member in members {
          let member = Member(self.sword, guild, member)
          guild.members[member.user.id] = member
        }

      /// GUILD_MEMBER_UPDATE
      case .guildMemberUpdate:
        let guild = self.sword.guilds[GuildID(data["guild_id"] as! String)!]!
        let member = Member(self.sword, guild, data)
        guild.members[member.user.id] = member
        self.sword.emit(.guildMemberUpdate, with: member)

      /// GUILD_ROLE_CREATE
      case .guildRoleCreate:
        let guild = self.sword.guilds[GuildID(data["guild_id"] as! String)!]!
        let role = Role(data["role"] as! [String: Any])
        guild.roles[role.id] = role
        self.sword.emit(.guildRoleCreate, with: (guild, role))

      /// GUILD_ROLE_DELETE
      case .guildRoleDelete:
        let guild = self.sword.guilds[GuildID(data["guild_id"] as! String)!]!
        let role = guild.roles[RoleID(data["role_id"] as! String)!]!
        guild.roles.removeValue(forKey: role.id)
        self.sword.emit(.guildRoleDelete, with: (guild, role))

      /// GUILD_ROLE_UPDATE
      case .guildRoleUpdate:
        let guild = self.sword.guilds[GuildID(data["guild_id"] as! String)!]!
        let role = Role(data["role"] as! [String: Any])
        guild.roles[role.id] = role
        self.sword.emit(.guildRoleUpdate, with: (guild, role))

      /// GUILD_UPDATE
      case .guildUpdate:
        let guild = Guild(self.sword, data, self.id)
        self.sword.guilds[guild.id] = guild
        self.sword.emit(.guildUpdate, with: guild)

      /// MESSAGE_CREATE
      case .messageCreate:
        let msg = Message(self.sword, data)
        self.sword.emit(.messageCreate, with: msg)

      /// MESSAGE_DELETE
      case .messageDelete:
        let channelId = ChannelID(data["channel_id"] as! String)!
        let messageId = MessageID(data["id"] as! String)!
        self.sword.emit(.messageDelete, with: (messageId, channelId))

      /// MESSAGE_BULK_DELETE
      case .messageDeleteBulk:
        let messageIds = (data["ids"] as! [String]).map({ MessageID($0)! })
        let channelId = ChannelID(data["channel_id"] as! String)!
        self.sword.emit(.messageDeleteBulk, with: (messageIds, channelId))

      /// MESSAGE_UPDATE
      case .messageUpdate:
        self.sword.emit(.messageUpdate, with: data)

      /// PRESENCE_UPDATE
      case .presenceUpdate:
        let userId = UserID((data["user"] as! [String: Any])["id"] as! String)!
        let presence = Presence(data)
        let guildID = GuildID(data["guild_id"] as! String)!
        self.sword.guilds[guildID]?.members[userId]?.presence = presence
        self.sword.emit(.presenceUpdate, with: (userId, presence))

      /// READY
      case .ready:
        self.sword.readyTimestamp = Date()
        self.sessionId = data["session_id"] as? String

        let guilds = data["guilds"] as! [[String: Any]]
        let dms = data["private_channels"] as! [[String: Any]]

        for guild in guilds {
          let guildID = GuildID(guild["id"] as! String)!
          self.sword.unavailableGuilds[guildID] = UnavailableGuild(guild, self.id)
        }

        for dm in dms {
          let recipients = dm["recipients"] as! [[String: Any]]
          for recipient in recipients {
            let recipientID = UserID(recipient["id"] as! String)!
            self.sword.dms[recipientID] = DMChannel(self.sword, dm)
          }
        }

        self.sword.shardsReady += 1
        self.sword.emit(.shardReady, with: self.id)

        if self.sword.shardsReady == self.sword.shardCount {
          self.sword.user = User(self.sword, data["user"] as! [String: Any])
          self.sword.emit(.ready, with: self.sword.user!)
        }

      /// MESSAGE_REACTION_ADD, MESSAGE_REACTION_REMOVE
      case .reactionAdd, .reactionRemove:
        let channelID = ChannelID(data["channel_id"] as! String)!
        let userID = UserID(data["user_id"] as! String)!
        let messageID = MessageID(data["message_id"] as! String)!
        let emoji = Emoji(data["emoji"] as! [String: Any])
        self.sword.emit(event, with: (channelID, userID, messageID, emoji))

      /// TYPING_START
      case .typingStart:
        #if !os(Linux)
        let timestamp = Date(timeIntervalSince1970: data["timestamp"] as! Double)
        #else
        let timestamp = Date(timeIntervalSince1970: Double(data["timestamp"] as! Int))
        #endif
        let userId = UserID(data["user_id"] as! String)!
        let channelId = ChannelID(data["channel_id"] as! String)!
        self.sword.emit(.typingStart, with: (channelId, userId, timestamp))

      /// USER_UPDATE
      case .userUpdate:
        self.sword.emit(.userUpdate, with: User(self.sword, data))

      /// VOICE_STATE_UPDATE
      case .voiceStateUpdate:
        let guildId = GuildID(data["guild_id"] as! String)!
        let channelId = ChannelID(data["channel_id"] as? String)
        let sessionId = data["session_id"] as! String
        let userId = UserID(data["user_id"] as! String)!

        let guild = self.sword.guilds[guildId]!

        if channelId != nil {
          let voiceState = VoiceState(data)

          guild.voiceStates[userId] = voiceState
          guild.members[userId]?.voiceState = voiceState

          self.sword.emit(.voiceChannelJoin, with: (userId, voiceState))
        }else {
          guild.voiceStates.removeValue(forKey: userId)
          guild.members[userId]?.voiceState = nil

          self.sword.emit(.voiceChannelLeave, with: userId)
        }

        self.sword.emit(.voiceStateUpdate, with: userId)

        guard userId == self.sword.user!.id else { return }

        if let channelId = channelId {
          self.sword.voiceManager.guilds[guildId] = PotentialConnection(channelId: channelId, userId: userId, sessionId: sessionId)
        }else {
          self.sword.voiceManager.leave(guildId)
        }

      /// VOICE_SERVER_UPDATE
      case .voiceServerUpdate:
        let guildId = GuildID(data["guild_id"] as! String)!
        let token = data["token"] as! String
        let endpoint = data["endpoint"] as! String

        guard let guild = self.sword.voiceManager.guilds[guildId] else { return }
        
        let payload = Payload(
          voiceOP: .identify,
          data: [
            "server_id": guildId.description,
            "user_id": self.sword.user!.id.description,
            "session_id": guild.sessionId,
            "token": token
          ]
        ).encode()

        self.sword.voiceManager.join(guildId, endpoint, payload)

      
      case .audioData:
        break
      case .connectionClose:
        break
      case .guildAvailable:
        break
      case .guildUnavailable:
        break
      case .payload:
        break
      case .resume:
        break
      case .shardReady:
        break
      case .voiceChannelJoin:
        break
      case .voiceChannelLeave:
        break
    }
  }

}
