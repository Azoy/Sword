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
  
  public var categoryChannels: [Channel.Category] {
    return channels.values.filter {
      $0 is Channel.Category
    } as! [Channel.Category]
  }
  
  public internal(set) var channels: [Snowflake: GuildChannel]
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
  public internal(set) var roles: [Role]
  public let splash: String?
  public let systemChannelId: Snowflake?
  
  public var textChannels: [Channel.Text] {
    return channels.values.filter {
      $0 is Channel.Text
    } as! [Channel.Text]
  }
  
  public let verificationLevel: Verification
  
  public var voiceChannels: [Channel.Voice] {
    return channels.values.filter {
      $0 is Channel.Voice
    } as! [Channel.Voice]
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
    self.id = try container.decode(Snowflake.self, forKey: .id)
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
      [ChannelHolder].self,
      forKey: .channels
    )
    
    self.channels = [Snowflake: GuildChannel]()
    
    for holder in channelHolders {
      holder.setGuildId(id)
      self.channels[holder.channel.id] = holder.channel
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
    self.region = try container.decode(
      Voice.Region.ID.self,
      forKey: .region
    )
    self.roles = try container.decode([Role].self, forKey: .roles)
    
    // After we decode roles, insert guild id into each one
    for i in roles.indices {
      roles[i].guildId = id
    }
    
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
    try container.encode(afkChannelId, forKey: .afkChannelId)
    try container.encode(afkTimeout, forKey: .afkTimeout)
    try container.encode(applicationId, forKey: .applicationId)
    
    let channelHolders: [ChannelHolder] = try channels.values.map {
      switch $0 {
      case let category as Channel.Category:
        return .category(category)
      case let text as Channel.Text:
        return .text(text)
      case let voice as Channel.Voice:
        return .voice(voice)
      default:
        throw EncodingError.invalidValue(
          $0,
          EncodingError.Context(
            codingPath: container.codingPath,
            debugDescription: "Unknown guild channel type"
          )
        )
      }
    }
    
    try container.encode(channelHolders, forKey: .channels)
    try container.encode(
      defaultMessageNotificationLevel,
      forKey: .defaultMessageNotificationLevel
    )
    try container.encode(embedChannelId, forKey: .embedChannelId)
    try container.encode(emojis, forKey: .emojis)
    try container.encode(
      explicitContentFilterLevel,
      forKey: .explicitContentFilterLevel
    )
    try container.encode(features, forKey: .features)
    try container.encode(icon, forKey: .icon)
    try container.encode(id, forKey: .id)
    try container.encode(isEmbedEnabled, forKey: .isEmbedEnabled)
    try container.encode(isLarge, forKey: .isLarge)
    try container.encode(isOwner, forKey: .isOwner)
    try container.encode(isUnavailable, forKey: .isUnavailable)
    try container.encode(isWidgetEnabled, forKey: .isWidgetEnabled)
    try container.encode(joinedAt, forKey: .joinedAt)
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
    
    public weak var guild: Guild? {
      guard let guildId = guildId else {
        return nil
      }
      
      return sword?.guilds[guildId]
    }
    
    public internal(set) var guildId: Snowflake?
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

extension Guild {
  enum ChannelHolder: Codable {
    case category(Channel.Category)
    case text(Channel.Text)
    case voice(Channel.Voice)
    
    var channel: GuildChannel {
      switch self {
      case let .category(category):
        return category
      case let .text(text):
        return text
      case let .voice(voice):
        return voice
      }
    }
    
    init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      
      let channelDecoding = try container.decode(ChannelDecoding.self)
      
      switch channelDecoding.type {
      case .guildCategory:
        self = .category(try container.decode(Channel.Category.self))
      case .guildText:
        self = .text(try container.decode(Channel.Text.self))
      case .guildVoice:
        self = .voice(try container.decode(Channel.Voice.self))
      default:
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "Unknown guild channel type"
        )
      }
    }
    
    func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      
      switch self {
      case let .category(category):
        try container.encode(category)
      case let .text(text):
        try container.encode(text)
      case let .voice(voice):
        try container.encode(voice)
      }
    }
    
    func setGuildId(_ guildId: Snowflake) {
      switch self {
      case let .category(category):
        category.guildId = guildId
      case let .text(text):
        text.guildId = guildId
      case let .voice(voice):
        voice.guildId = guildId
      }
    }
  }
}
