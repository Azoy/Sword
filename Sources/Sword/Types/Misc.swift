//
//  Misc.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation

extension Sword {
  /// Represents an identify structure sent through the gateway
  struct GatewayIdentify: Encodable {
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
  
  /// Represents the info received from /gateway/bot
  public struct GatewayInfo: Decodable {
    /// The websocket url to connect the bot
    public let url: URL
    
    /// The number of recommended shards
    public let shards: UInt8
  }
}

extension Sword.GatewayIdentify {
  /// Identify connection properties
  struct Properties: Encodable {
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
