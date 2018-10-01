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
  public let channels: [GuildChannel]
  public let defaultMessageNotificationLevel: DefaultMessageNotification
  public let embedChannelId: Snowflake?
  public let emojis: [Emoji]
  public let explicitContentFilterLevel: ExplicitContentFilter
  public let features: [Feature]
  public let icon: String?
  public let id: Snowflake
  public let isEmbedEnabled: Bool?
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
  
  public var textChannels: [GuildText] {
    return channels.filter {
      $0 is GuildText
    } as! [GuildText]
  }
  
  public let verificationLevel: Verification
  
  public var voiceChannels: [GuildVoice] {
    return channels.filter {
      $0 is GuildVoice
    } as! [GuildVoice]
  }
  
  public let voiceStates: [Voice.State]?
  public let widgetChannelId: Snowflake?
  
  /// Used to map json keys to swift keys
  enum CodingKeys: String, CodingKey {
    case afkChannelId = "afk_channel_id"
    case afkTimeout = "afk_timeout"
    case applicationId = "application_id"
    case channels
    case defaultMessageNotificationLevel = "default_message_notifications"
    case embedChannelId = "embed_channel_id"
    case emojis
    case explicitContentFilterLevel = "explicit_content_filter"
    case features
    case icon
    case id
    case isEmbedEnabled = "embed_enabled"
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
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.afkChannelId = try container.decodeIfPresent(
      Snowflake.self,
      forKey: .afkChannelId
    )
    self.afkTimeout = try container.decode(UInt64.self, forKey: .afkTimeout)
    self.applicationId = try container.decodeIfPresent(
      Snowflake.self,
      forKey: .applicationId
    )
    
    let channelHolders = try container.decode(
      [GuildChannelHolder].self,
      forKey: .channels
    )
    
    self.channels = channelHolders.map {
      if case let .category(category) = $0 {
        return category
      }
      
      if case let .text(text) = $0 {
        return text
      }
      
      if case let .voice(voice) = $0 {
        return voice
      }
    }
    
    self.defaultMessageNotificationLevel = try container.decode(
      DefaultMessageNotification.self,
      forKey: .defaultMessageNotificationLevel
    )
    self.embedChannelId = try container.decodeIfPresent(
      Snowflake.self,
      forKey: .embedChannelId
    )
    self.emojis = try container.decode([Emoji].self, forKey: .emojis)
    self.explicitContentFilterLevel = try container.decode(
      ExplicitContentFilter.self,
      forKey: .explicitContentFilterLevel
    )
    self.features = try container.decode([Feature].self, forKey: .features)
    self.icon = try container.decodeIfPresent(String.self, forKey: .icon)
    self.id = try container.decode(Snowflake.self, forKey: .id)
    self.isEmbedEnabled = try container.decodeIfPresent(
      Bool.self,
      forKey: .isEmbedEnabled
    )
    self.isLarge = try container.decodeIfPresent(Bool.self, forKey: .isLarge)
    self.isOwner = try container.decodeIfPresent(Bool.self, forKey: .isOwner)
    self.isUnavailable = try container.decodeIfPresent(
      Bool.self,
      forKey: .isUnavailable
    )
    self.isWidgetEnabled = try container.decodeIfPresent(
      Bool.self,
      forKey: .isWidgetEnabled
    )
    self.joinedAt = try container.decodeIfPresent(Date.self, forKey: .joinedAt)
    self.memberCount = try container.decodeIfPresent(
      UInt64.self,
      forKey: .memberCount
    )
    self.members = try container.decodeIfPresent(
      [Member].self,
      forKey: .members
    )
    self.name = try container.decode(String.self, forKey: .name)
    self.ownerId = try container.decode(Snowflake.self, forKey: .ownerId)
    self.permissions = try container.decodeIfPresent(
      UInt64.self,
      forKey: .permissions
    )
    self.region = try container.decode(Voice.Region.ID.self, forKey: .region)
    self.roles = try container.decode([Role].self, forKey: .roles)
    self.splash = try container.decodeIfPresent(String.self, forKey: .splash)
    self.systemChannelId = try container.decodeIfPresent(
      Snowflake.self,
      forKey: .systemChannelId
    )
    self.verificationLevel = try container.decode(
      Verification.self,
      forKey: .verificationLevel
    )
    self.voiceStates = try container.decodeIfPresent(
      [Voice.State].self,
      forKey: .voiceStates
    )
    self.widgetChannelId = try container.decodeIfPresent(
      Snowflake.self,
      forKey: .widgetChannelId
    )
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.afkChannelId, forKey: .afkChannelId)
    try container.encode(self.afkTimeout, forKey: .afkTimeout)
    try container.encode(self.applicationId, forKey: .applicationId)
    
    let channelHolders: [GuildChannelHolder] = self.channels.map {
      if let category = $0 as? GuildCategory {
        return .category(category)
      }
      
      if let text = $0 as? GuildText {
        return .text(text)
      }
      
      if let voice = $0 as? GuildVoice {
        return .voice(voice)
      }
    }
    
    try container.encode(channelHolders, forKey: .channels)
    try container.encode(
      self.defaultMessageNotificationLevel,
      forKey: .defaultMessageNotificationLevel
    )
    try container.encode(self.embedChannelId, forKey: .embedChannelId)
    try container.encode(self.emojis, forKey: .emojis)
    try container.encode(
      self.explicitContentFilterLevel,
      forKey: .explicitContentFilterLevel
    )
    try container.encode(self.features, forKey: .features)
    try container.encode(self.icon, forKey: .icon)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.isEmbedEnabled, forKey: .isEmbedEnabled)
    try container.encode(self.isLarge, forKey: .isLarge)
    try container.encode(self.isOwner, forKey: .isOwner)
    try container.encode(self.isUnavailable, forKey: .isUnavailable)
    try container.encode(self.isWidgetEnabled, forKey: .isWidgetEnabled)
    try container.encode(self.joinedAt, forKey: .joinedAt)
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
    
    public let guildId: Snowflake
    public let isDeafened: Bool
    public let isMuted: Bool
    public let joinedAt: Date
    public let nick: String?
    public let roleIds: [Snowflake]
    public let user: User
    
    enum CodingKeys: String, CodingKey {
      case guildId
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

enum GuildChannelHolder: Codable {
  case category(GuildCategory)
  case text(GuildText)
  case voice(GuildVoice)
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    
    if let category = try? container.decode(GuildCategory.self) {
      self = .category(category)
    }
    
    if let text = try? container.decode(GuildText.self) {
      self = .text(text)
    }
    
    if let voice = try? container.decode(GuildVoice.self) {
      self = .voice(voice)
    }
    
    throw DecodingError.dataCorruptedError(
      in: container,
      debugDescription: "Unknown guild channel type"
    )
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    
    if case let .category(category) = self {
      try container.encode(category)
    }
    
    if case let .text(text) = self {
      try container.encode(text)
    }
    
    if case let .voice(voice) = self {
      try container.encode(voice)
    }
  }
}
