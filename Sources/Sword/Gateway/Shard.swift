//
//  Shard.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation
import WebSocket

extension Sword {
  /// Shard - Represents a unique session to a portion of the guilds a bot is
  ///         connected to.
  class Shard : GatewayHandler {
    /// The shard ID
    let id: UInt8
    
    /// The WebSocket session
    var session: WebSocket?
    
    /// The parent class
    weak var sword: Sword?
    
    /// Event loop to handle payloads on
    var worker: Worker
    
    /// Instantiates a Shard
    ///
    /// - parameter id: The shard id
    /// - parameter sword: The parent class
    init(id: UInt8, _ sword: Sword?) {
      self.id = id
      self.sword = sword
      self.worker = MultiThreadedEventLoopGroup(numThreads: 1)
    }
    
    /// Handles deinitialization of a shard
    deinit {
      do {
        try worker.syncShutdownGracefully()
      } catch {
        Sword.log(.warning, "Unable to shutdown event loop for shard: \(id).")
      }
    }
    
    /// Handles text being sent through the gateway
    ///
    /// - parameter ws: WebSocket session to prevent cycles
    /// - parameter text: String that was sent through the gateway
    func handleText(_ ws: WebSocket, _ text: String) {
      guard let data = text.data(using: .utf8) else {
        Sword.log(.error, "Unable to convert payload text to data")
        return
      }
      
      do {
        let payload = try Sword.decoder.decode(Payload.self, from: data)
        Sword.log(.info, "\(payload)")
      } catch {
        Sword.log(.error, "Unable to correctly decode payload data. Error: \(error)")
      }
    }
    
    /// Reconnects the shard to Discord
    func reconnect() {
      // Ideally there would be code here
    }
  }
}
