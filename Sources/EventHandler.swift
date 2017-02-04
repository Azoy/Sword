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

    guard let event = Event(rawValue: eventName) else {
      return
    }

    if self.sword.options.disabledEvents.contains(event) {
      return
    }

    switch event {

      /// CHANNEL_CREATE
      case .channelCreate:
        if (data["is_private"] as! Bool) {
          self.sword.emit(.channelCreate, with: DMChannel(self.sword, data))
        }else {
          let channel = Channel(self.sword, data)
          self.sword.guilds[channel.guildId!]!.channels[channel.id] = channel
          self.sword.emit(.channelCreate, with: channel)
        }
        break

      /// CHANNEL_DELETE
      case .channelDelete:
        if (data["is_private"] as! Bool) {
          self.sword.emit(.channelDelete, with: DMChannel(self.sword, data))
        }else {
          let channel = Channel(self.sword, data)
          self.sword.guilds[channel.guildId!]!.channels.removeValue(forKey: channel.id)
          self.sword.emit(.channelDelete, with: channel)
        }
        break

      /// CHANNEL_UPDATE
      case .channelUpdate:
        self.sword.emit(.channelUpdate, with: Channel(self.sword, data))
        break

      /// GUILD_BAN_ADD
      case .guildBanAdd:
        self.sword.emit(.guildBanAdd, with: data["guild_id"] as! String, User(self.sword, data))
        break

      /// GUILD_BAN_REMOVE
      case .guildBanRemove:
        self.sword.emit(.guildBanRemove, with: data["guild_id"] as! String, User(self.sword, data))
        break

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

        if self.sword.options.isCachingAllMembers && guild.members.count != guild.memberCount {
          self.requestOfflineMembers(for: guild.id)
        }

        break

      /// GUILD_DELETE
      case .guildDelete:
        let guildId = data["id"] as! String

        self.sword.guilds.removeValue(forKey: guildId)

        if (data["unavailable"] as! Bool) {
          let unavailableGuild = UnavailableGuild(data, self.id)
          self.sword.unavailableGuilds[guildId] = unavailableGuild
          self.sword.emit(.guildUnavailable, with: unavailableGuild)
        }else {
          self.sword.emit(.guildDelete, with: guildId)
        }
        break

      /// GUILD_EMOJIS_UPDATE
      case .guildEmojisUpdate:
        var emitEmojis: [Emoji] = []
        let emojis = data["emojis"] as! [[String: Any]]
        for emoji in emojis {
          emitEmojis.append(Emoji(emoji))
        }
        self.sword.emit(.guildEmojisUpdate, with: data["guild_id"] as! String, emitEmojis)
        break

      /// GUILD_INTEGRATIONS_UPDATE
      case .guildIntegrationsUpdate:
        self.sword.emit(.guildIntegrationsUpdate, with: data["guild_id"] as! String)
        break

      /// GUILD_MEMBER_ADD
      case .guildMemberAdd:
        let guildId = data["guild_id"] as! String
        let member = Member(self.sword, data)
        self.sword.guilds[guildId]!.members[member.user.id] = member
        self.sword.emit(.guildMemberAdd, with: guildId, member)
        break

      /// GUILD_MEMBER_REMOVE
      case .guildMemberRemove:
        let guildId = data["guild_id"] as! String
        let user = User(self.sword, data["user"] as! [String: Any])
        self.sword.guilds[guildId]!.members.removeValue(forKey: user.id)
        self.sword.emit(.guildMemberRemove, with: guildId, user)
        break

      /// GUILD_MEMBERS_CHUNK
      case .guildMembersChunk:
        let guildId = data["guild_id"] as! String
        let members = data["members"] as! [[String: Any]]
        for member in members {
          let member = Member(self.sword, member)
          self.sword.guilds[guildId]!.members[member.user.id] = member
        }
        break

      /// GUILD_MEMBER_UPDATE
      case .guildMemberUpdate:
        let guildId = data["guild_id"] as! String
        let member = Member(self.sword, data)
        self.sword.guilds[guildId]!.members[member.user.id] = member
        self.sword.emit(.guildMemberUpdate, with: member)
        break

      /// GUILD_ROLE_CREATE
      case .guildRoleCreate:
        let guildId = data["guildId"] as! String
        let role = Role(data["role"] as! [String: Any])
        self.sword.guilds[guildId]!.roles[role.id] = role
        self.sword.emit(.guildRoleCreate, with: guildId, role)
        break

      /// GUILD_ROLE_DELETE
      case .guildRoleDelete:
        let guildId = data["guild_id"] as! String
        let roleId = data["role_id"] as! String
        self.sword.guilds[guildId]!.roles.removeValue(forKey: roleId)
        self.sword.emit(.guildRoleDelete, with: guildId, roleId)
        break

      /// GUILD_ROLE_UPDATE
      case .guildRoleUpdate:
        let guildId = data["guild_id"] as! String
        let role = Role(data["role"] as! [String: Any])
        self.sword.guilds[guildId]!.roles[role.id] = role
        self.sword.emit(.guildRoleUpdate, with: guildId, role)
        break

      /// GUILD_UPDATE
      case .guildUpdate:
        self.sword.emit(.guildUpdate, with: Guild(self.sword, data, self.id))
        break

      /// MESSAGE_CREATE
      case .messageCreate:

        let msg = Message(self.sword, data)
        self.sword.emit(.messageCreate, with: msg)
        break

      /// MESSAGE_DELETE
      case .messageDelete:
        self.sword.emit(.messageDelete, with: data["id"] as! String, data["channel_id"] as! String)
        break

      /// MESSAGE_BULK_DELETE
      case .messageDeleteBulk:
        let messages = data["ids"] as! [String]
        self.sword.emit(.messageDeleteBulk, with: messages, data["channel_id"] as! String)
        break

      /// MESSAGE_UPDATE
      case .messageUpdate:
        self.sword.emit(.messageUpdate, with: data["id"] as! String, data["channel_id"] as! String)
        break

      /// PRESENCE_UPDATE
      case .presenceUpdate:
        let userId = (data["user"] as! [String: Any])["id"] as! String
        let presence = Presence(data)
        self.sword.guilds[data["guild_id"] as! String]!.members[userId]!.presence = presence
        self.sword.emit(.presenceUpdate, with: userId, presence)
        break

      /// READY
      case .ready:
        self.sword.readyTimestamp = Date()
        self.sessionId = data["session_id"] as? String

        let guilds = data["guilds"] as! [[String: Any]]

        for guild in guilds {
          self.sword.unavailableGuilds[guild["id"] as! String] = UnavailableGuild(guild, self.id)
        }

        self.sword.user = User(self.sword, data["user"] as! [String: Any])
        self.sword.emit(.ready, with: self.sword.user!)
        break

      /// TYPING_START
      case .typingStart:
        #if !os(Linux)
        let timestamp = Date(timeIntervalSince1970: data["timestamp"] as! Double)
        #else
        let timestamp = Date(timeIntervalSince1970: Double(data["timestamp"] as! Int))
        #endif
        self.sword.emit(.typingStart, with: data["channel_id"] as! String, data["user_id"] as! String, timestamp)
        break

      /// USER_UPDATE
      case .userUpdate:
        self.sword.emit(.userUpdate, with: User(self.sword, data))
        break

      /// VOICE_STATE_UPDATE
      case .voiceStateUpdate:
        let guildId = data["guild_id"] as! String
        let channelId = data["channel_id"] as? String
        let sessionId = data["session_id"] as! String
        let userId = data["user_id"] as! String

        if channelId != nil {
          let voiceState = VoiceState(data)

          self.sword.guilds[guildId]!.members[userId]?.voiceState = voiceState

          self.sword.emit(.voiceChannelJoin, with: userId, voiceState)
        }else {
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
        break

      /// VOICE_SERVER_UPDATE
      case .voiceServerUpdate:
        let guildId = data["guild_id"] as! String
        let token = data["token"] as! String
        let endpoint = data["endpoint"] as! String

        guard self.sword.voiceManager.guilds[guildId] != nil else { return }

        let payload = Payload(voiceOP: .identify, data: ["server_id": guildId, "user_id": self.sword.user!.id, "session_id": self.sword.voiceManager.guilds[guildId]!["sessionId"], "token": token]).encode()

        self.sword.voiceManager.join(guildId, endpoint, payload)
        break

      default:
        break
    }
  }

}
