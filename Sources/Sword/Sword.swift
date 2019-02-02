//
//  Sword.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation
import Async

/// Swift meets Discord
open class Sword {
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
  
  /// Application blocker
  var promise: Promise<()>?
  
  /// Shared URLSession
  let session = URLSession.shared
  
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
  
  /// Blocks application for shards to run
  func block() {
    if promise == nil {
      promise = worker.eventLoop.newPromise(Void.self)
    }
    
    do {
      try promise?.futureResult.wait()
    } catch {
      Sword.log(.error, "Unable to block Sword.")
    }
  }
  
  /// Connects the bot
  public func connect() {
    let promise = worker.eventLoop.newPromise(GatewayInfo.self)
    
    getGateway { _, info, error in
      guard let info = info else {
        Sword.log(.error, error!.message)
        promise.fail(error: error!)
        return
      }
      
      promise.succeed(result: info)
    }
    
    promise.futureResult.whenFailure { error in
      Sword.log(.error, error.localizedDescription)
    }
    
    do {
      let info = try promise.futureResult.wait()
      
      shardManager.shardCount = info.shards
      
      for i in 0 ..< info.shards {
        shardManager.spawn(i, to: info.url)
      }
      
      block()
    } catch {
      Sword.log(.error, error.localizedDescription)
    }
  }
  
  /// Disconnects the bot
  public func disconnect() {
    shardManager.disconnect()
    unblock()
  }
  
  /// Used to debug the bot's current _trace for its shards
  public func dumpTraces() {
    if !Logger.isEnabled {
      Logger.isEnabled = true
      
      defer { Logger.isEnabled = false }
    }
    
    for shard in shardManager.shards {
      Sword.log(.info, "Shard \(shard.id): \(shard.trace)")
    }
  }
  
  /// Get's the bot's initial gateway information for the websocket
  public func getGateway(
    then: @escaping (Sword, GatewayInfo?, Sword.Error?) -> ()
  ) {
    request(.gateway) { sword, data, error in
      guard let data = data else {
        then(sword, nil, error)
        return
      }
      
      do {
        then(sword, try Sword.decoder.decode(GatewayInfo.self, from: data), nil)
      } catch {
        then(sword, nil, Sword.Error(error.localizedDescription))
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
  
  /// Unblocks application from keeping shards alive, you're on your own
  func unblock() {
    promise?.succeed()
  }
  
}
