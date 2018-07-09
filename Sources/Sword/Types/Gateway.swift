//
//  Gateway.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Indicates that a message contains _trace
protocol TraceHolder {
  /// Array of servers we're connected to
  var trace: [String] { get }
}

/// Represents a hello message received from the gateway
struct GatewayHello: TraceHolder, Codable {
  /// Interval in ms that we need to heartbeat to gateway
  let heartbeatInterval: Int
  
  /// Array of servers we're connected to
  let trace: [String]
  
  /// Used to map json keys to swift keys
  enum CodingKeys: String, CodingKey {
    case heartbeatInterval = "heartbeat_interval"
    case trace = "_trace"
  }
}

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

/// Represents a ready message received from the gateway
struct GatewayReady: TraceHolder, Codable {
  /// Id of current session
  let sessionId: String
  
  /// Array of server we're connected to
  let trace: [String]
  
  /// Bot user that connected to gateway
  let user: User
  
  /// Version of the gateway we connected to
  let version: UInt8
  
  enum CodingKeys: String, CodingKey {
    case sessionId = "session_id"
    case trace = "_trace"
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

/// Represents a resumed message received from the gateway
struct GatewayResumed: TraceHolder, Codable {
  /// Array of servers we're connected to
  let trace: [String]
  
  /// Used to map json keys to swift keys
  enum CodingKeys: String, CodingKey {
    case trace = "_trace"
  }
}
