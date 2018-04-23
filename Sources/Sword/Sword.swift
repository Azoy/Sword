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
  
  /// Used to encode stuff to send off to Discord
  static let encoder = JSONEncoder()
  
  /// Application blocker
  let promise: Promise<Void>
  
  /// Customizable options used when setting up the bot
  public var options: Options
  
  /// Shared URLSession
  let session = URLSession.shared
  
  /// Shard Manager
  lazy var shardManager = Shard.Manager()
  
  /// Bot's Chuck E Cheese token to the magical world of Discord's API
  let token: String
  
  /// Application event loop
  let worker = MultiThreadedEventLoopGroup(numThreads: 1)
  
  /// Instantiates a Sword instance
  ///
  /// - parameter token: The bot token used to connect to Discord's API
  /// - parameter options: Customizable options used when setting up the bot
  public init(token: String, options: Options = Options()) {
    self.options = options
    self.token = token
    self.promise = worker.eventLoop.newPromise(Void.self)
    
    if options.willLog {
      Sword.Logger.isEnabled = true
    }
  }
  
  /// Blocks application for shards to run
  func block() {
    do {
      try promise.futureResult.wait()
    } catch {
      Sword.log(.error, "Unable to block Sword.")
    }
  }
  
  /// Connects the bot
  public func connect() {
    getGateway { sword, info, error in
      guard let info = info else {
        return
      }
      
      sword?.shardManager.sword = sword
      
      for i in 0 ..< info.shards {
        sword?.shardManager.spawn(i, to: info.url.absoluteString)
      }
    }
    
    block()
  }
  
  /// Disconnects the bot
  public func disconnect() {
    unblock()
  }
  
  /// Get's the bot's initial gateway information for the websocket
  public func getGateway(
    then: @escaping (Sword?, GatewayInfo?, Sword.Error?) -> ()
  ) {
    request(.gateway()) { [weak self] data, error in
      guard let data = data else {
        then(self, nil, error)
        return
      }
      
      do {
        try then(self, Sword.decoder.decode(GatewayInfo.self, from: data), nil)
      } catch {
        then(self, nil, Sword.Error(error.localizedDescription))
      }
    }
  }
  
  /// Sends a message to a channel
  ///
  /// - parameter content: Message content to send to channel
  /// - parameter channelId: The channel ID to send this message to
  public func send(
    _ content: Message.Content,
    to channelId: String,
    then: ((Message?, Error?) -> ())? = nil
  ) {
    print("Get pranked")
  }
  
  /// Unblocks application from keeping shards alive, you're on your own
  func unblock() {
    promise.succeed()
  }
  
}
