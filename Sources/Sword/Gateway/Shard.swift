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
    
    /// The last sequence number for this shard
    var lastSeq: Int?
    
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
        
        switch payload.op {
        case .dispatch:
          lastSeq = payload.s
        case .hello:
          identify(from: payload)
        default:
          break
        }
        
      } catch {
        Sword.log(.error, "Unable to correctly decode payload data. Error: \(error)")
      }
    }
    
    func handleClose(_ ws: WebSocket, _ error: Swift.Error) {
      print(error.localizedDescription)
    }
    
    /// Sends identify payload
    ///
    /// - parameter payload: Hello payload to identify to
    func identify(from payload: Payload) {
      guard let sword = sword else {
        Sword.log(.error, "Unable to capture Sword to identify on shard: \(id)")
        return
      }
      
      #if os(macOS)
      let os = "macOS"
      #endif
      
      let identify = GatewayIdentify(
        largeThreshold: 50,
        properties: GatewayIdentify.Properties(
          browser: "Sword",
          device: "Sword",
          os: os
        ),
        shard: [id, sword.shardManager.shardCount],
        token: sword.token,
        willCompress: false
      )
      
      do {
        let identifyData = try Sword.encoder.encode(identify)
        let json = try Sword.decoder.decode(JSON.self, from: identifyData)
        let payload = Payload(d: json, op: .identify, s: nil, t: nil)
        let data = try Sword.encoder.encode(payload)
        session?.send(data)
      } catch {
        Sword.log(.error, error.localizedDescription)
      }
    }
    
    /// Reconnects the shard to Discord
    func reconnect() {
      // Ideally there would be code here
    }
  }
}
