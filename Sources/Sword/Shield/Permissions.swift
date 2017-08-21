//
//  Permissions.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Permission enum to prevent wrong permission checks
public enum Permission: Int {

  /// Allows creation of instant invites
  case createInstantInvite = 0x1

  /// Allows kicking members
  case kickMembers = 0x2

  /// Allows banning members
  case banMembers = 0x4

  /// Allows all permissions and bypasses channel permission overwrites
  case administrator = 0x8

  /// Allows management and editing of channels
  case manageChannels = 0x10

  /// Allows management and editing of the guild
  case manageGuild = 0x20

  /// Allows for the addition of reactions to messages
  case addReactions = 0x40

  /// Allows for the user to view a server's audit log
  case viewAuditLog = 0x80

  /// Allows viewing of a channel. The channel will not appear for users without this permission
  case viewChannel = 0x400

  /// Allows for sending messages in a channel.
  case sendMessages = 0x800

  /// Allows for sending of /tts messages
  case sendTTSMessages = 0x1000

  /// Allows for deletion of other users messages
  case manageMessages = 0x2000

  /// Links sent by this user will be auto-embedded
  case embedLinks = 0x4000

  /// Allows for uploading images and files
  case attachFiles = 0x8000

  /// Allows for reading of message history
  case readMessageHistory = 0x10000

  /// Allows for using the @everyone tag to notify all users in a channel, and the @here tag to notify all online users in a channel
  case mentionEveryone = 0x20000

  /// Allows the usage of custom emojis from other servers
  case useExternalEmojis = 0x40000

  /// Allows for joining of a voice channel
  case connect = 0x100000

  /// Allows for speaking in a voice channel
  case speak = 0x200000

  /// Allows for muting members in a voice channel
  case muteMembers = 0x400000

  /// Allows for deafening of members in a voice channel
  case deafenMembers = 0x800000

  /// llows for moving of members between voice channels
  case moveMembers = 0x1000000

  /// Allows for using voice-activity-detection in a voice channel
  case useVad = 0x2000000

  /// Allows for modification of own nickname
  case changeNickname = 0x4000000

  /// Allows for modification of other users nicknames
  case manageNicknames = 0x8000000

  /// Allows management and editing of roles
  case manageRoles = 0x10000000

  /// Allows management and editing of webhooks
  case manageWebhooks = 0x20000000

  /// Allows management and editing of emojis
  case manageEmojis = 0x40000000

}
