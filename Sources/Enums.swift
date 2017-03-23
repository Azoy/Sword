//
//  Enums.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Organize OAuth2 scopes
public enum Scope: String {

case bot,
     connections,
     email,
     identify,
     guilds,
     joinGuilds = "guilds.join",
     joinGroupDM = "gdm.join",
     readMessages = "messages.read",
     rpc,
     rpcApi = "rpc.api",
     readRPCNotifications = "rpc.notifications.read",
     incomingWebhook = "webhook.incoming"

}

/// Organize all dispatch events
enum OP: Int {

  case dispatch,
       heartbeat,
       identify,
       statusUpdate,
       voiceStateUpdate,
       voiceServerPing,
       resume,
       reconnect,
       requestGuildMember,
       invalidSession,
       hello,
       heartbeatACK

}

/// Organize all voice evnets
enum VoiceOP: Int {

  case identify,
       selectProtocol,
       ready,
       heartbeat,
       sessionDescription,
       speaking

}

/// Organize all websocket close codes
enum CloseOP: Int {

  case unknown = 1000,
       unknownError = 4000,
       unknownOPCode,
       decodeError,
       notAuthenticated,
       authenticationFailed,
       alreadyAuthenticated,
       invalidSeq = 4007,
       rateLimited,
       sessionTimeout,
       invalidShard,
       shardingRequired

}

/// Organize all ws dispatch events
public enum Event: String {

  /**
   Fired when audio data is received from voice connection

   ### Usage ###
   ```swift
   connection.on(.audioData) { data in
     let audioData = data[0] as! Data
   }
   ```
  */
  case audioData

  /**
   Fired when a channel is created

   ### Usage ###
   ```swift
   bot.on(.channelCreate) { data in
     let channel = data[0] as! Channel
   }
  */
  case channelCreate = "CHANNEL_CREATE"

    /**
     Fired when a channel is deleted

     ### Usage ###
     ```swift
     bot.on(.channelDelete) { data in
       let channel = data[0] as! Channel
     }
     ```
    */
  case channelDelete = "CHANNEL_DELETE"

    /**
     Fired when a channel is updated

     ### Usage ###
     ```swift
     bot.on(.channelUpdate) { data in
       let channel = data[0] as! Channel
     }
     ```
    */
  case channelUpdate = "CHANNEL_UPDATE"

    /**
     Fired when voice connection dies (self emitted)

     ### Usage ###
     ```swift
     connection.on(.connectionClose) { _ in
       kill(process.processIdentifier, SIGKILL)
     }
     ```
    */
  case connectionClose

    /**
     Fired when a guild is available (This is not guildCreate)

     ### Usage ###
     ```swift
     bot.on(.guildAvailable) { data in
       let guild = data[0] as! Guild
     }
     ```
    */
  case guildAvailable

    /**
     Fired when a member of a guild is banned

     ### Usage ###
     ```swift
     bot.on(.guildBanAdd) { data in
       let guild = data[0] as! Guild
       let user = data[1] as! User
     }
     ```
    */
  case guildBanAdd = "GUILD_BAN_ADD"

    /**
     Fired when a member of a guild is unbanned

     ### Usage ###
     ```swift
     bot.on(.guildBanRemove) { data in
       let guild = data[0] as! Guild
       let user = data[1] as! User
     }
     ```
    */
  case guildBanRemove = "GUILD_BAN_REMOVE"

    /**
     Fired when a guild is created

     ### Usage ###
     ```swift
     bot.on(.guildCreate) { data in
       let guild = data[0] as! Guild
     }
     ```
    */
  case guildCreate = "GUILD_CREATE"

    /**
     Fired when a guild is deleted

     ### Usage ###
     ```swift
     bot.on(.guildDelete) { data in
       let guild = data[0] as! Guild
     }
     ```
    */
  case guildDelete = "GUILD_DELETE"

    /**
     Fired when a guild's custom emojis are created/deleted/updated

     ### Usage ###
     ```swift
     bot.on(.guildEmojisUpdate) { data in
       let guild = data[0] as! Guild
       let emojis = data[1] as! [Emoji]
     }
     ```
    */
  case guildEmojisUpdate = "GUILD_EMOJIS_UPDATE"

    /**
     Fired when a guild updates it's integrations

     ### Usage ###
     ```swift
     bot.on(.guildIntegrationsUpdate) { data in
       let guild = data[0] as! Guild
     }
     ```
    */
  case guildIntegrationsUpdate = "GUILD_INTEGRATIONS_UPDATE"

    /**
     Fired when a user joins a guild

     ### Usage ###
     ```swift
     bot.on(.guildMemberAdd) { data in
       let guild = data[0] as! Guild
       let member = data[1] as! Member
     }
     ```
    */
  case guildMemberAdd = "GUILD_MEMBER_ADD"

    /**
     Fired when a member leaves a guild

     ### Usage ###
     ```swift
     bot.on(.guildMemberRemove) { data in
       let guild = data[0] as! Guild
       let user = data[1] as! User
     }
     ```
    */
  case guildMemberRemove = "GUILD_MEMBER_REMOVE"

    /**
     Fired when a member of a guild is updated

     ### Usage ###
     ```swift
     bot.on(.guildMemberUpdate) { data in
       let member = data[0] as! Member
     }
     ```
    */
  case guildMemberUpdate = "GUILD_MEMBER_UPDATE"

  /// :nodoc:
  case guildMembersChunk = "GUILD_MEMBERS_CHUNK"

    /**
     Fired when a role is created in a guild

     ### Usage ###
     ```swift
     bot.on(.guildRoleCreate) { data in
       let guild = data[0] as! Guild
       let role = data[1] as! Role
     }
     ```
    */
  case guildRoleCreate = "GUILD_ROLE_CREATE"

    /**
     Fired when a role is deleted in a guild

     ### Usage ###
     ```swift
     bot.on(.guildRoleDelete) { data in
       let guild = data[0] as! Guild
       let roleId = data[1] as! String
     }
     ```
    */
  case guildRoleDelete = "GUILD_ROLE_DELETE"

    /**
     Fired when a role is updated in a guild

     ### Usage ###
     ```swift
     bot.on(.guildRoleUpdate) { data in
       let guild = data[0] as! Guild
       let role = data[1] as! Role
     }
     ```
    */
  case guildRoleUpdate = "GUILD_ROLE_UPDATE"

    /**
     Fired when a guild becomes unavailable

     ### Usage ###
     ```swift
     bot.on(.guildUnavailable) { data in
       let guild = data[0] as! UnavailableGuild
     }
     ```
    */
  case guildUnavailable

    /**
     Fired when a guild is updated

     ### Usage ###
     ```swift
     bot.on(.guildUpdate) { data in
       let guild = data[0] as! Guild
     }
     ```
    */
  case guildUpdate = "GUILD_UPDATE"

    /**
     Fired when a message is created

     ### Usage ###
     ```swift
     bot.on(.messageCreate) { data in
       let msg = data[0] as! Message
     }
     ```
    */
  case messageCreate = "MESSAGE_CREATE"

    /**
     Fired when a message is deleted

     ### Usage ###
     ```swift
     bot.on(.messageDelete) { data in
      guard let msg = data[0] as? Message else {
        //data has returned a string
        return
      }
      let channel = data[1] as! Channel
     }
     ```
    */
  case messageDelete = "MESSAGE_DELETE"

    /**
     Fired when a large chunk of messages are deleted

     ### Usage ###
     ```swift
     bot.on(.messageDeleteBulk) { data in
       let messageIds = data[0] as! [String]
       let channel = data[1] as! Channel
     }
     ```
    */
  case messageDeleteBulk = "MESSAGE_DELETE_BULK"

    /**
     Fired when a message is updated

     ### Usage ###
     ```swift
     bot.on(.messageUpdate) { data in
       let msgId = data[0] as! String
       let channelId = data[1] as! String
     }
     ```
    */
  case messageUpdate = "MESSAGE_UPDATE"

    /**
     Fired when a user's presences is updated

     ### Usage ###
     ```swift
     bot.on(.presenceUpdate) { data in
       let userId = data[0] as! String
       let presence = data[1] as! Presence
     }
     ```
    */
  case presenceUpdate = "PRESENCE_UPDATE"

    /**
     Fired when the bot is ready to receive events

     ### Usage ###
     ```swift
     bot.on(.ready) { data in
       let user = data[0] as! User
     }
     ```
    */
  case ready = "READY"

  /// :nodoc:
  case resume = "RESUME"

    /**
     Fired when a shard becomes ready

     ### Usage ###
     ```swift
     bot.on(.shardReady) { data in
       let shardId = data[0] as! Int
     }
     ```
    */
  case shardReady

    /**
     Fired when someone starts typing a message

     ### Usage ###
     ```swift
     bot.on(.typingStart) { data in
       let channel = data[0] as! Channel
       let userId = data[1] as! String
       let timestamp = data[2] as! Date
     }
     ```
    */
  case typingStart = "TYPING_START"

    /**
     Fired when a user updates their info

     ### Usage ###
     ```swift
     bot.on(.userUpdate) { data in
       let user = data[0] as! User
     }
     ```
    */
  case userUpdate = "USER_UPDATE"

    /**
     Fired when someone joins a voice channel

     ### Usage ###
     ```swift
     bot.on(.voiceChannelJoin) { data in
       let userId = data[0] as! String
       let voiceState = data[1] as! VoiceState
     }
     ```
    */
  case voiceChannelJoin

    /**
     Fired when someone leaves a voice channel

     ### Usage ###
     ```swift
     bot.on(.voiceChannelLeave) { data in
       let userId = data[0] as! String
     }
     ```
    */
  case voiceChannelLeave

    /**
     Fired when someone joins/leaves/moves a voice channel

     ### Usage ###
     ```swift
     bot.on(.voiceStateUpdate) { data in
       let userId = data[0] as! String
     }
     ```
    */
  case voiceStateUpdate = "VOICE_STATE_UPDATE"

  /// :nodoc:
  case voiceServerUpdate = "VOICE_SERVER_UPDATE"

}
