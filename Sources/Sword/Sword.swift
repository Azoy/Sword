//
//  Sword.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation
import NIO

/// Swift meets Discord
open class Sword {
  /// Maps routes to buckets for rate limiting
  //var buckets = [String: Bucket]()
  
  /// Mappings from command names/aliases to base command
  var commandMap = [String: Command]()
  
  /// Used to decode stuff from Discord
  static let decoder = JSONDecoder()
  
  /// Used to provide sword to children
  static var decodingInfo: CodingUserInfoKey {
    return CodingUserInfoKey(rawValue: "sword")!
  }
  
  /// Used to encode stuff to send off to Discord
  static let encoder = JSONEncoder()
  
  /// Mappings from guild id to guild
  public internal(set) var guilds = [Snowflake: Guild]()
  
  /// Interface to events
  public let on = EventHandler.self
  
  /// Customizable options used when setting up the bot
  public var options: Options
  
  /// Shard Manager
  lazy var shardManager = Shard.Manager(self)
  
  /// Bot's Chuck E Cheese token to the magical world of Discord's API
  let token: String
  
  /// Mappings from guild id to unavailable guild
  public internal(set) var unavailableGuilds = [Snowflake: UnavailableGuild]()
  
  /// The Bot's Discord user
  public internal(set) var user: User?
  
  /// Application event loop
  let worker = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
  
  /// Instantiates a Sword instance
  ///
  /// - parameter token: The bot token used to connect to Discord's API
  /// - parameter options: Customizable options used when setting up the bot
  public init(token: String, options: Options = Options()) {
    self.options = options
    self.token = token
    
    if options.logging {
      Logger.isEnabled = true
    }
    
    Sword.decoder.userInfo[Sword.decodingInfo] = self
  }
  
  deinit {
    try! worker.syncShutdownGracefully()
  }
  
  /// Connects the bot
  public func connect() {
    getGateway { sword, result in
      switch result {
      case .failure(let error):
        Sword.log(.error, error.message)
      case .success(let info):
        sword.shardManager.shardCount = info.shards
        
        for i in 0 ..< info.shards {
          sword.shardManager.spawn(i, to: info.url)
        }
      }
    }
  }
  
  /// Disconnects the bot
  public func disconnect() {
    shardManager.disconnect()
  }
  
  /// Used to debug the bot's current _trace for its shards
  public func dumpTraces() {
    Logger.isEnabled = true
    
    defer { Logger.isEnabled = options.logging }
    
    for shard in shardManager.shards {
      Sword.log(.info, "Shard \(shard.id): \(shard.trace)")
    }
  }
  
  /// Get's the bot's initial gateway information for the websocket
  public func getGateway(
    then: @escaping (Sword, Result<GatewayInfo, Sword.Error>) -> ()
  ) {
    try? request(.gateway) { sword, result in
      switch result {
      case .failure(let error):
        then(sword, .failure(error))
      case.success(let data):
        do {
          let info = try Sword.decoder.decode(GatewayInfo.self, from: data)
          then(sword, .success(info))
        } catch {
          then(sword, .failure(Sword.Error(error.localizedDescription)))
        }
      }
    }
  }
  
  /// Used to to the bot's current _trace for its shards
  public func getTraces() -> [UInt8: [String]] {
    var traces = [UInt8: [String]]()
    for shard in shardManager.shards {
      traces[shard.id] = shard.trace
    }
    
    return traces
  }
}
