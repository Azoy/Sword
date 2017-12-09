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
  func handleEvent(
    _ data: [String: Any],
    _ eventName: String
  ) {

    guard let event = Event(rawValue: eventName) else {
      self.sword.log("Received unknown event: \(eventName)")
      return
    }

    guard !self.sword.options.disabledEvents.contains(event) else {
      return
    }

    switch event {

    /// CHANNEL_CREATE
    case .channelCreate:
      switch data["type"] as! Int {
      case 0:
        let channel = GuildText(self.sword, data)
        self.sword.emit(.channelCreate, with: channel)

      case 1:
        let dm = DM(self.sword, data)
        self.sword.emit(.channelCreate, with: dm)
          
      case 2:
        let channel = GuildVoice(self.sword, data)
        self.sword.emit(.channelCreate, with: channel)
          
      case 3:
        let group = GroupDM(self.sword, data)
        self.sword.emit(.channelCreate, with: group)
        
      case 4:
        let category = GuildCategory(self.sword, data)
        self.sword.emit(.channelCreate, with: category)

      default: return
      }

    /// CHANNEL_DELETE
    case .channelDelete:
      switch data["type"] as! Int {
      case 0, 2, 4:
        let guildId = Snowflake(data["guild_id"])!
        guard let guild = self.sword.guilds[guildId] else {
          return
        }
        let channelId = Snowflake(data["id"])!
        guard let channel = guild.channels.removeValue(forKey: channelId) else {
            return
        }
        self.sword.emit(.channelDelete, with: channel)

      case 1:
        let recipient = (data["recipients"] as! [[String: Any]])[0]
        let userId = Snowflake(recipient["id"])!
        guard let dm = self.sword.dms.removeValue(forKey: userId) else {
          return
        }
        self.sword.emit(.channelDelete, with: dm)

      case 3:
        let channelId = Snowflake(data["id"])!
        guard let group = self.sword.groups.removeValue(forKey: channelId) else {
          return
        }
        self.sword.emit(.channelDelete, with: group)

      default: return
      }

    /// CHANNEL_PINS_UPDATE
    case .channelPinsUpdate:
      let channelId = Snowflake(data["channel_id"])!
      let timestamp = data["last_pin_timestamp"] as? String
      guard let channel = self.sword.getChannel(for: channelId) else {
        return
      }
      self.sword.emit(.channelPinsUpdate, with: (channel, timestamp?.date)
      )
      
    /// CHANNEL_UPDATE
    case .channelUpdate:
      switch data["type"] as! Int {
      case 0, 2, 4:
        let guildId = Snowflake(data["guild_id"])!
        let channelId = Snowflake(data["id"])!
        guard let channel = self.sword.guilds[guildId]!.channels[channelId] as? Updatable else {
          return
        }
        channel.update(data)
        self.sword.emit(.channelUpdate, with: channel)
          
      case 3:
        let group = GroupDM(self.sword, data)
        self.sword.groups[group.id] = group
        self.sword.emit(.channelUpdate, with: group)

      default: return
      }

    /// GUILD_BAN_ADD & GUILD_BAN_REMOVE
    case .guildBanAdd, .guildBanRemove:
      let guildId = Snowflake(data["guild_id"])!
      guard let guild = self.sword.guilds[guildId] else {
        return
      }
      let user = User(self.sword, data["user"] as! [String: Any])
      self.sword.emit(event, with: (guild, user))

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

      if self.sword.options.willCacheAllMembers
        && guild.members.count != guild.memberCount {
        self.requestOfflineMembers(for: guild.id)
      }

    /// GUILD_DELETE
    case .guildDelete:
      let guildId = Snowflake(data["id"])!
      guard let guild = self.sword.guilds.removeValue(forKey: guildId) else {
        return
      }

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
      let guildId = Snowflake(data["guild_id"])!
      guard let guild = self.sword.guilds[guildId] else {
        return
      }
      guild.emojis = emojis
      self.sword.emit(.guildEmojisUpdate, with: (guild, emojis))

    /// GUILD_INTEGRATIONS_UPDATE
    case .guildIntegrationsUpdate:
      let guildId = Snowflake(data["guild_id"])!
      guard let guild = self.sword.guilds[guildId] else {
        return
      }
      self.sword.emit(.guildIntegrationsUpdate, with: guild)

    /// GUILD_MEMBER_ADD
    case .guildMemberAdd:
      let guildId = Snowflake(data["guild_id"])!
      guard let guild = self.sword.guilds[guildId] else {
        return
      }
      let member = Member(self.sword, guild, data)
      guild.members[member.user.id] = member
      self.sword.emit(.guildMemberAdd, with: (guild, member))

    /// GUILD_MEMBER_REMOVE
    case .guildMemberRemove:
      let guildId = Snowflake(data["guild_id"])!
      guard let guild = self.sword.guilds[guildId] else {
        return
      }
      let user = User(self.sword, data["user"] as! [String: Any])
      guild.members.removeValue(forKey: user.id)
      self.sword.emit(.guildMemberRemove, with: (guild, user))

    /// GUILD_MEMBERS_CHUNK
    case .guildMembersChunk:
      let guildId = Snowflake(data["guild_id"])!
      guard let guild = self.sword.guilds[guildId] else {
        return
      }
      let members = data["members"] as! [[String: Any]]
      for member in members {
        let member = Member(self.sword, guild, member)
        guild.members[member.user.id] = member
      }

    /// GUILD_MEMBER_UPDATE
    case .guildMemberUpdate:
      let guildId = Snowflake(data["guild_id"])!
      guard let guild = self.sword.guilds[guildId] else {
        return
      }
      let member = Member(self.sword, guild, data)
      guild.members[member.user.id] = member
      self.sword.emit(.guildMemberUpdate, with: member)

    /// GUILD_ROLE_CREATE
    case .guildRoleCreate:
      let guildId = Snowflake(data["guild_id"])!
      guard let guild = self.sword.guilds[guildId] else {
        return
      }
      let role = Role(data["role"] as! [String: Any])
      guild.roles[role.id] = role
      self.sword.emit(.guildRoleCreate, with: (guild, role))

    /// GUILD_ROLE_DELETE
    case .guildRoleDelete:
      let guildId = Snowflake(data["guild_id"])!
      guard let guild = self.sword.guilds[guildId] else {
        return
      }
      let roleId = Snowflake(data["role_id"])!
      guard let role = guild.roles[roleId] else {
        return
      }
      guild.roles.removeValue(forKey: role.id)
      self.sword.emit(.guildRoleDelete, with: (guild, role))

    /// GUILD_ROLE_UPDATE
    case .guildRoleUpdate:
      let guildId = Snowflake(data["guild_id"])!
      guard let guild = self.sword.guilds[guildId] else {
        return
      }
      let role = Role(data["role"] as! [String: Any])
      guild.roles[role.id] = role
      self.sword.emit(.guildRoleUpdate, with: (guild, role))

    /// GUILD_UPDATE
    case .guildUpdate:
      let guildId = Snowflake(data["id"])!
      guard let guild = self.sword.guilds[guildId] else {
        return
      }
      guild.update(data) 
      self.sword.emit(.guildUpdate, with: guild)

    /// MESSAGE_CREATE
    case .messageCreate:
      let msg = Message(self.sword, data)
      
      if let channel = msg.channel as? GuildText {
        channel.lastMessageId = msg.id
      }
      
      self.sword.emit(.messageCreate, with: msg)

    /// MESSAGE_DELETE
    case .messageDelete:
      let channelId = Snowflake(data["channel_id"])!
      guard let channel = self.sword.getChannel(for: channelId) else {
        return
      }
      let messageId = Snowflake(data["id"])!
      self.sword.emit(.messageDelete, with: (messageId, channel))

    /// MESSAGE_BULK_DELETE
    case .messageDeleteBulk:
      let channelId = Snowflake(data["channel_id"])!
      guard let channel = self.sword.getChannel(for: channelId) else {
        return
      }
      let messageIds = (data["ids"] as! [String]).map({ Snowflake($0)! })
      self.sword.emit(.messageDeleteBulk, with: (messageIds, channel))
      
    /// MESSAGE_REACTION_REMOVE_ALL
    case .messageReactionRemoveAll:
      let channelId = Snowflake(data["channel_id"])!
      guard let channel = self.sword.getChannel(for: channelId) else {
        return
      }
      let messageId = Snowflake(data["message_id"])!
      self.sword.emit(.messageReactionRemoveAll, with: (messageId, channel))
      
    /// MESSAGE_UPDATE
    case .messageUpdate:
      self.sword.emit(.messageUpdate, with: data)

    /// PRESENCE_UPDATE
    case .presenceUpdate:
      let userId = Snowflake((data["user"] as! [String: Any])["id"])!
      let presence = Presence(data)
      let guildID = Snowflake(data["guild_id"])!
      
      guard self.sword.options.willCacheAllMembers else {
        guard presence.status == .offline else { return }
        
        self.sword.guilds[guildID]?.members.removeValue(forKey: userId)
        return
      }
      
      self.sword.guilds[guildID]?.members[userId]?.presence = presence
      self.sword.emit(.presenceUpdate, with: (userId, presence))

    /// READY
    case .ready:
      self.sword.readyTimestamp = Date()
      self.sessionId = data["session_id"] as? String
      
      let guilds = data["guilds"] as! [[String: Any]]

      for guild in guilds {
        let guildID = Snowflake(guild["id"])!
        self.sword.unavailableGuilds[guildID] = UnavailableGuild(guild, self.id)
      }
      
      self.sword.shardsReady += 1
      self.sword.emit(.shardReady, with: self.id)

      if self.sword.shardsReady == self.sword.shardCount {
        self.sword.user = User(self.sword, data["user"] as! [String: Any])
        self.sword.emit(.ready, with: self.sword.user!)
      }

    /// MESSAGE_REACTION_ADD, MESSAGE_REACTION_REMOVE
    case .reactionAdd, .reactionRemove:
      let channelId = Snowflake(data["channel_id"])!
      guard let channel = self.sword.getChannel(for: channelId) else {
        return
      }
      let userID = Snowflake(data["user_id"])!
      let messageID = Snowflake(data["message_id"])!
      let emoji = Emoji(data["emoji"] as! [String: Any])
      self.sword.emit(event, with: (channel, userID, messageID, emoji))

    /// TYPING_START
    case .typingStart:
      #if !os(Linux)
      let timestamp = Date(timeIntervalSince1970: data["timestamp"] as! Double)
      #else
      let timestamp = Date(
        timeIntervalSince1970: Double(data["timestamp"] as! Int)
      )
      #endif
      let channelId = Snowflake(data["channel_id"])!
      guard let channel = self.sword.getChannel(for: channelId) else {
        return
      }
      let userId = Snowflake(data["user_id"])!
      self.sword.emit(.typingStart, with: (channel, userId, timestamp))

    /// USER_UPDATE
    case .userUpdate:
      self.sword.emit(.userUpdate, with: User(self.sword, data))

    /// VOICE_STATE_UPDATE
    case .voiceStateUpdate:
      let guildId = Snowflake(data["guild_id"])!
      guard let guild = self.sword.guilds[guildId] else {
        return
      }
      let channelId = Snowflake(data["channel_id"])
      let sessionId = data["session_id"] as! String
      let userId = Snowflake(data["user_id"])!

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

      
      #if os(macOS) || os(Linux)
      guard userId == self.sword.user!.id else { return }

      if let channelId = channelId {
        self.sword.voiceManager.guilds[guildId] =
          PotentialConnection(
            channelId: channelId,
            userId: userId,
            sessionId: sessionId
        )
      }else {
        self.sword.voiceManager.leave(guildId)
      }
      #endif

    /// VOICE_SERVER_UPDATE
    case .voiceServerUpdate:
      #if os(macOS) || os(Linux)
      let guildId = Snowflake(data["guild_id"])!
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
      )

      self.sword.voiceManager.join(guildId, endpoint, payload)
      #else
      return
      #endif

      
    case .audioData:
      return
    case .connectionClose:
      return
    case .disconnect:
      return
    case .guildAvailable:
      return
    case .guildUnavailable:
      return
    case .payload:
      return
    case .resume:
      return
    case .resumed:
      return
    case .shardReady:
      return
    case .voiceChannelJoin:
      return
    case .voiceChannelLeave:
      return
    }
  }

}
