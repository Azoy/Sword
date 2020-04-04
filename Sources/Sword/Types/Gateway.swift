//
//  Gateway.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Represents a hello message received from the gateway
struct GatewayHello: Codable {
  /// Interval in ms that we need to heartbeat to gateway
  let heartbeatInterval: Int
  
  /// Used to map json keys to swift keys
  enum CodingKeys: String, CodingKey {
    case heartbeatInterval = "heartbeat_interval"
  }
}

/// Represents an identify structure sent through the gateway
struct GatewayIdentify: Codable {
  /// Whether we will receive presence and typing events.
  let guildSubscriptions: Bool
  
  /// Total number of members where gateway will stop sending offline members
  let largeThreshold: UInt8
  
  /// Connection properties
  let properties: Properties
  
  /// Represents the current shard
  let shard: [UInt8]
  
  /// Authentication token
  let token: String
  
  /// Whether or not this connection supports etf
  let willCompress: Bool
  
  /// Used to map json keys to swift keys
  enum CodingKeys: String, CodingKey {
    case guildSubscriptions = "guild_subscriptions"
    case largeThreshold = "large_threshold"
    case properties
    case shard
    case token
    case willCompress = "compress"
  }
}

extension GatewayIdentify {
  /// Identify connection properties
  struct Properties: Codable {
    /// Library name (Sword)
    let browser: String
    
    /// Library name (Sword)
    let device: String
    
    /// Operating system name (macOS, iOS, Linux, etc)
    let os: String
    
    /// Used to map json keys to swift keys
    enum CodingKeys: String, CodingKey {
      case browser = "$browser"
      case device = "$device"
      case os = "$os"
    }
  }
}

/// Represents a bot's session start limits on the gateway
public struct SessionStartLimit: Codable {
  /// Remaining number of session starts the current user is allowed
  public let remaining: UInt
  
  /// Number of milliseconds after which the limit resets
  public let resetAfter: UInt
  
  /// Total number of session starts the current user is allowed
  public let total: UInt
  
  enum CodingKeys: String, CodingKey {
    case remaining = "remaining"
    case resetAfter = "reset_after"
    case total = "total"
  }
}

/// Represents the info received from /gateway/bot
public struct GatewayInfo: Codable {
  /// The websocket url to connect the bot
  public let url: String
  
  /// Information on the current session start limit
  public let sessionStartLimit: SessionStartLimit
  
  /// The number of recommended shards
  public let shards: UInt8
    
  enum CodingKeys: String, CodingKey {
    case url = "url"
    case sessionStartLimit = "session_start_limit"
    case shards = "shards"
  }
}

/// Represents a ready message received from the gateway
struct GatewayReady: Codable {
  /// Id of current session
  let sessionId: String
  
  /// Array of unavailable guilds the user is in
  let unavailableGuilds: [UnavailableGuild]
  
  /// Bot user that connected to gateway
  let user: User
  
  /// Version of the gateway we connected to
  let version: UInt8
  
  enum CodingKeys: String, CodingKey {
    case sessionId = "session_id"
    case unavailableGuilds = "guilds"
    case user
    case version = "v"
  }
}

/// Represents a resume structure sent through the gateway
struct GatewayResume: Codable {
  /// Authentication token
  let token: String
  
  /// Id of current session
  let sessionId: String
  
  /// Sequence number of last dispatch event
  let seq: Int?
  
  /// Used to map json keys to swift keys
  enum CodingKeys: String, CodingKey {
    case token
    case sessionId = "session_id"
    case seq
  }
}
