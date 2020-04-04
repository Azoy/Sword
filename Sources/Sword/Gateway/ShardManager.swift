//
//  ShardManager.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

extension Sword {
  /// Compression of Discord's gateway this implementation uses
  static let gatewayCompression = "zlib-stream"
  
  /// Encoding of Discord's gateway this implementation uses
  static let gatewayEncoding = "json"
  
  /// Version of Discord's gateway this implementation uses
  static let gatewayVersion: UInt8 = 6
}

extension Shard {
  /// Handles multiple shards
  class Manager {
    /// Amount of shards allocated for this bot
    var shardCount: UInt8 = 0
    
    /// Maps shard ids to their connected host
    var shardHosts = [UInt8: String]()
    
    /// Array of shards this bot is in
    var shards = [Shard]()
    
    /// The parent class
    let sword: Sword
    
    /// Instantiates a Shard.Manager instance
    ///
    /// - parameter sword: Parent class
    init(_ sword: Sword) {
      self.sword = sword
    }
    
    /// Spawns a specific shard connected to an initial host
    ///
    /// - parameter id: The shard ID
    /// - parameter host: The gateway URL that this shard needs to connect to
    func spawn(_ id: UInt8, to host: String) {
      // Append version
      var host = "\(host)?v=\(Sword.gatewayVersion)"
      
      // Append encoding
      host += "&encoding=\(Sword.gatewayEncoding)"
      
      if sword.options.transportCompression {
        // Append compression
        host += "&compress=\(Sword.gatewayCompression)"
      }
      
      shardHosts[id] = host
      
      Sword.log(.info, "Spawning shard \(id) connected to \(host)")
      
      let shard = Shard(id: id, sword)
      shard.connect(to: host)
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
