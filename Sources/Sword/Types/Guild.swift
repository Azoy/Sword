//
//  Guild.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation

public class Guild: Codable, _SwordChild {
  public internal(set) weak var sword: Sword?
  
  public let afkChannelId: Snowflake?
  public let afkTimeout: UInt64
  public let applicationId: Snowflake?
  //public let channels: [GuildChannel]
  public let defaultMessageNotificationLevel: DefaultMessageNotification
  public let embedChannelId: Snowflake?
  public let embedEnabled: Bool?
  public let emojis: [Emoji]
  public let explicitContentFilterLevel: ExplicitContentFilter
  public let features: [Feature]
  public let icon: String?
  public let id: Snowflake
  public let isLarge: Bool?
  public let isOwner: Bool?
  public let isUnavailable: Bool?
  public let isWidgetEnabled: Bool?
  public let joinedAt: Date?
  public let memberCount: UInt64?
  public let members: [Member]?
  public let name: String
  public let ownerId: Snowflake
  public let permissions: UInt64?
  public let region: Voice.Region.ID
  public let roles: [Role]
  public let splash: String?
  public let systemChannelId: Snowflake?
  public let verificationLevel: Verification
  public let voiceStates: [Voice.State]?
  public let widgetChannelId: Snowflake?
  
  /// Used to map json keys to swift keys
  enum CodingKeys: String, CodingKey {
    case afkChannelId = "afk_channel_id"
    case afkTimeout = "afk_timeout"
    case applicationId = "application_id"
    //case channels
    case defaultMessageNotificationLevel = "default_message_notifications"
    case embedChannelId = "embed_channel_id"
    case embedEnabled = "embed_enabled"
    case emojis
    case explicitContentFilterLevel = "explicit_content_filter"
    case features
    case icon
    case id
    case isLarge = "large"
    case isOwner = "owner"
    case isUnavailable = "unavailable"
    case isWidgetEnabled = "widget_enabled"
    case joinedAt = "joined_at"
    case memberCount = "member_count"
    case members
    case name
    case ownerId = "owner_id"
    case permissions
    case region
    case roles
    case splash
    case systemChannelId = "system_channel_id"
    case verificationLevel = "verification_level"
    case voiceStates = "voice_states"
    case widgetChannelId = "widget_channel_id"
  }
}

extension Guild {
  public enum DefaultMessageNotification: UInt8, Codable {
    case all
    case mentions
  }
  
  public enum ExplicitContentFilter: UInt8, Codable {
    case disabled
    case withoutRoles
    case all
  }
  
  public enum Feature: String, Codable {
    case vipVoice = "VIP_REGIONS"
    case vanityUrl = "VANITY_URL"
    case inviteSplash = "INVITE_SPLASH"
    case verified = "VERIFIED"
    case moreEmojis = "MORE_EMOJI"
  }
  
  public struct Member: Codable, _SwordChild {
    public internal(set) weak var sword: Sword?
    
    public let isDeafened: Bool
    public let isMuted: Bool
    public let joinedAt: Date
    public let nick: String?
    public let roleIds: [Snowflake]
    public let user: User
    
    enum CodingKeys: String, CodingKey {
      case isDeafened = "deaf"
      case isMuted = "mute"
      case joinedAt = "joined_at"
      case nick
      case roleIds = "roles"
      case user
    }
  }
  
  public enum MFA: UInt8, Codable {
    case none
    case elevated
  }
  
  public enum SearchQualifier {
    case channel
    case role
  }
  
  public enum Verification: UInt8, Codable {
    case none
    case low
    case medium
    case high
    case veryHigh
  }
}

public struct UnavailableGuild: Codable {
  public let id: Snowflake
  public let isUnavailable: Bool
  
  enum CodingKeys: String, CodingKey {
    case id
    case isUnavailable = "unavailable"
  }
}
