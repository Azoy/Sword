//
//  Sword.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation
import NIO
import AsyncHTTPClient

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
  
  /// Interface to event storage
  let emit = EventEmitter.self
  
  /// Used to encode stuff to send off to Discord
  static let encoder = JSONEncoder()
  
  /// WebSocket CLient to execute websocket requests
  let gateway: WebSocketClient
  
  /// Mappings from guild id to guild
  public internal(set) var guilds = [Snowflake: Guild]()
  
  /// HTTP Client to execute rest requests
  let http: HTTPClient
  
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
    
    let httpConfig = HTTPClient.Configuration(tlsConfiguration: .clientDefault)
    http = HTTPClient(
      eventLoopGroupProvider: .shared(worker),
      configuration: httpConfig
    )
    
    let webSocketConfig = WebSocketClient.Configuration(
      tlsConfiguration: .clientDefault,
      maxFrameSize: 1 << 31
    )
    gateway = WebSocketClient(
      eventLoopGroupProvider: .shared(worker),
      configuration: webSocketConfig
    )
    
    Sword.decoder.userInfo[Sword.decodingInfo] = self
  }
  
  deinit {
    try! http.syncShutdown()
    try! gateway.syncShutdown()
    try! worker.syncShutdownGracefully()
  }
  
  /// Connects the bot
  public func connect() {
    do {
      let info = try getGateway().wait()
      print(info)
      shardManager.shardCount = info.shards
      
      // Default is to handle all shards
      var shards = Array(0 ..< info.shards)
      
      // If we have specific shards to handle, use those
      if !options.shards.isEmpty {
        shards = options.shards
      }
      
      for i in shards {
        shardManager.spawn(i, to: info.url)
      }
      
      if options.blocking {
        RunLoop.main.run()
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  
  /// Disconnects the bot
  public func disconnect() {
    shardManager.disconnect()
    
    if options.blocking {
      CFRunLoopStop(RunLoop.main.getCFRunLoop())
    }
  }
}
