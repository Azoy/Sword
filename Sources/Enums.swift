//
//  Enums.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Organize all dispatch events
enum OPCode: Int {

  case dispatch, heartbeat, identify, statusUpdate, voiceStateUpdate, voiceServerPing, resume, reconnect, requestGuildMember, invalidSession, hello, heartbeatACK

}

enum VoiceOPCode: Int {

  case identify, selectProtocol, ready, heartbeat, sessionDescription, speaking

}

/// Organize all websocket close codes
enum CloseCode: Int {

  case unknown = 1000, unknownError = 4000, unknownOPCode, decodeError, notAuthenticated, authenticationFailed, alreadyAuthenticated, invalidSeq, rateLimited, sessionTimeout, invalidShard

}

/// Organize all ws dispatch events
public enum Event: String {

  /// Fired when a channel is created
  case channelCreate = "CHANNEL_CREATE"

  /// Fired when a channel is updated
  case channelUpdate = "CHANNEL_UPDATE"

  /// Fired when a channel is deleted
  case channelDelete = "CHANNEL_DELETE"

  case connectionClose

  /// Fired when a guild becomes available
  case guildAvailable

  /// Fired when a guild is created
  case guildCreate = "GUILD_CREATE"

  /// Fired when a guild is updated
  case guildUpdate = "GUILD_UPDATE"

  /// Fired when a guild is deleted
  case guildDelete = "GUILD_DELETE"

  /// Fired when a member gets banned from a guild
  case guildBanAdd = "GUILD_BAD_ADD"

  /// Fired when a member gets unbanned from a guild
  case guildBanRemove = "GUILD_BAN_REMOVE"

  /// Fired when a guild emoji is created, updated, or removed
  case guildEmojisUpdate = "GUILD_EMOJIS_UPDATE"

  /// Fired when a guild integration is created, updated, or removed
  case guildIntegrationsUpdate = "GUILD_INTEGRATIONS_UPDATE"

  /// Fired when a user joins a guild
  case guildMemberAdd = "GUILD_MEMBER_ADD"

  /// Fired when a user leaves a guild
  case guildMemberRemove = "GUILD_MEMBER_REMOVE"

  /// Fired when a user is updated in a guild
  case guildMemberUpdate = "GUILD_MEMBER_UPDATE"

  /// This is an internal event, but fires when bot requests for offline members
  case guildMembersChunk = "GUILD_MEMBERS_CHUNK"

  /// Fired when a role is created
  case guildRoleCreate = "GUILD_ROLE_CREATE"

  /// Fired when a role is updated
  case guildRoleUpdate = "GUILD_ROLE_UPDATE"

  /// Fired when a role is deleted
  case guildRoleDelete = "GUILD_ROLE_DELETE"

  /// Fired when a guild becomes unavilable
  case guildUnavailable

  /// Fired when a message is created
  case messageCreate = "MESSAGE_CREATE"

  /// Fired when a message is updated
  case messageUpdate = "MESSAGE_UPDATE"

  /// Fired when a message is deleted
  case messageDelete = "MESSAGE_DELETE"

  /// Fired when a large chunk of messages are deleted
  case messageDeleteBulk = "MESSAGE_DELETE_BULK"

  /// Fired when someone changes status
  case presenceUpdate = "PRESENCE_UPDATE"

  /// Fired when a shard is ready
  case ready = "READY"

  /// Fired when a shard is resumed
  case resume = "RESUME"

  /// Fired when someone starts typing
  case typingStart = "TYPING_START"

  /// Fired when the bot changes username, email, etc
  case userSettingsUpdate = "USER_SETTINGS_UPDATE"

  /// Fired when a user updates their username, email, etc
  case userUpdate = "USER_UPDATE"

  case voiceChannelJoin

  case voiceChannelLeave

  /// Fired when someone joins/moves/leaves a voice channel
  case voiceStateUpdate = "VOICE_STATE_UPDATE"

  /// Fired when a voice server is updated (change region, etc)
  case voiceServerUpdate = "VOICE_SERVER_UPDATE"

}
