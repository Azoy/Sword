//
//  Shard.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation
import Starscream

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
    
    /// Instantiates a Shard
    ///
    /// - parameter id: The shard id
    /// - parameter sword: The parent class
    init(id: UInt8, _ sword: Sword?) {
      self.id = id
      self.sword = sword
    }
    
    /// Handles text being sent through the gateway
    ///
    /// - parameter text: String that was sent through the gateway
    func handleText(_ text: String) {
      print(text)
    }
    
    /// Reconnects the shard to Discord
    func reconnect() {
      // Ideally there would be code here
    }
  }
}
