//
//  Misc.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Represents an identify structure sent through the gateway
struct GatewayIdentify: Codable {
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

/// Represents the info received from /gateway/bot
public struct GatewayInfo: Decodable {
  /// The websocket url to connect the bot
  public let url: URL
  
  /// The number of recommended shards
  public let shards: UInt8
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
