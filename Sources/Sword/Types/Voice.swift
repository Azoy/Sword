//
//  Voice.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

// Voice namespace
public enum Voice {}

extension Voice {
  public struct Region: Codable {
    public let id: ID
    public let isCustom: Bool
    public let isDeprecated: Bool
    public let isOptimal: Bool
    public let isVip: Bool
    public let name: String
    
    enum CodingKeys: String, CodingKey {
      case id
      case isCustom = "custom"
      case isDeprecated = "deprecated"
      case isOptimal = "optimal"
      case isVip = "vip"
      case name
    }
  }
  
  public struct State: Codable, _SwordChild {
    public internal(set) weak var sword: Sword?
    
    public let channelId: Snowflake?
    
    public var guild: Guild? {
      guard let guildId = guildId else {
        return nil
      }
      
      return sword?.guilds[guildId]
    }
    
    public let guildId: Snowflake?
    public let isDeafened: Bool
    public let isMuted: Bool
    public let isSelfDeafened: Bool
    public let isSelfMuted: Bool
    public let isSuppressed: Bool
    public let sessionId: String
    public let userId: Snowflake
    
    enum CodingKeys: String, CodingKey {
      case channelId = "channel_id"
      case guildId = "guild_id"
      case isDeafened = "deaf"
      case isMuted = "mute"
      case isSelfDeafened = "self_deaf"
      case isSelfMuted = "self_mute"
      case isSuppressed = "suppress"
      case sessionId = "session_id"
      case userId = "user_id"
    }
  }
}

extension Voice.Region {
  public enum ID: String, Codable {
    case amsterdam
    case brazil
    case euCentral = "eu-central"
    case euWest = "eu-west"
    case frankfurt
    case hongkong
    case japan
    case london
    case russia
    case singapore
    case sydney
    case usCentral = "us-central"
    case usEast = "us-east"
    case usSouth = "us-south"
    case usWest = "us-west"
    case vipUSEast = "vip-us-east"
    case vipUSWest = "vip-us-west"
    case vipAmsterdam = "vip-amsterdam"
    
    public var isVip: Bool {
      return self.rawValue.hasPrefix("vip")
    }
  }
}
