//
//  Enums.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2016 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Organize all dispatch events
enum OPCode: Int {

  case dispatch, heartbeat, identify, statusUpdate, voiceStateUpdate, voiceServerPing, resume, reconnect, requestGuildMember, invalidSession, hello, heartbeatACK

}

/// Organize all websocket close codes
enum CloseCode: Int {

  case unknownError = 4000, unknownOPCode, decodeError, notAuthenticated, authenticationFailed, alreadyAuthenticated, invalidSeq, rateLimited, sessionTimeout, invalidShard

}

/// Organize all ws dispatch events
enum Event: String {

  case ready = "READY"
  case resume = "RESUME"
  case channelCreate = "CHANNEL_CREATE"
  case channelUpdate = "CHANNEL_UPDATE"
  case channelDelete = "CHANNEL_DELETE"
  case guildCreate = "GUILD_CREATE"
  case guildUpdate = "GUILD_UPDATE"
  case guildDelete = "GUILD_DELETE"
  case guildBanAdd = "GUILD_BAD_ADD"
  case guildBanRemove = "GUILD_BAN_REMOVE"
  case guildEmojisUpdate = "GUILD_EMOJIS_UPDATE"
  case guildIntegrationsUpdate = "GUILD_INTEGRATIONS_UPDATE"
  case guildMemberAdd = "GUILD_MEMBER_ADD"
  case guildMemberRemove = "GUILD_MEMBER_REMOVE"
  case guildMemberUpdate = "GUILD_MEMBER_UPDATE"
  case guildMembersChunk = "GUILD_MEMBERS_CHUNK"
  case guildRoleCreate = "GUILD_ROLE_CREATE"
  case guildRoleUpdate = "GUILD_ROLE_UPDATE"
  case guildRoleDelete = "GUILD_ROLE_DELETE"
  case messageCreate = "MESSAGE_CREATE"
  case messageUpdate = "MESSAGE_UPDATE"
  case messageDelete = "MESSAGE_DELETE"
  case messageDeleteBulk = "MESSAGE_DELETE_BULK"
  case presenceUpdate = "PRESENCE_UPDATE"
  case typingStart = "TYPING_START"
  case userSettingsUpdate = "USER_SETTINGS_UPDATE"
  case userUpdate = "USER_UPDATE"
  case voiceStateUpdate = "VOICE_STATE_UPDATE"
  case voiceServerUpdate = "VOICE_SERVER_UPDATE"

}
