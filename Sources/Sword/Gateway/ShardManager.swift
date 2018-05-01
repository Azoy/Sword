//
//  ShardManager.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

extension Sword {
  /// Version of Discord's gateway this implementation uses
  static let gatewayVersion = 6
}

extension Shard {
  /// Handles multiple shards
  class Manager {
    /// Amount of shards allocated for this bot
    var shardCount: UInt8 = 0
    
    /// Array of shards this bot is in
    var shards = [Shard]()
    
    /// The parent class
    weak var sword: Sword?
    
    /// Spawns a specific shard connected to an initial host
    ///
    /// - parameter id: The shard ID
    /// - parameter host: The gateway URL that this shard needs to connect to
    func spawn(_ id: UInt8, to host: String) {
      Sword.log(
        .info,
        "Spawning shard \(id) connected to \(host)/?v=\(Sword.gatewayVersion)&encoding=json"
      )
      
      let shard = Shard(id: id, sword)
      shard.connect(to: host + "/?v=\(Sword.gatewayVersion)&encoding=json")
      shards.append(shard)
    }
    
    /// Disconnects all shards from the gateway
    func disconnect() {
      for shard in shards {
        shard.disconnect()
      }
    }
  }
}
