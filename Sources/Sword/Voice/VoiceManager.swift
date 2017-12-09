//
//  VoiceManager.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

#if os(macOS) || os(Linux)

/// Creates VoiceManager
class VoiceManager {

  // MARK: Properties

  /// Object of connections mapped by guildId
  var connections = [Snowflake: VoiceConnection]()

  /// Used to determine whether or not voiceServerUpdate is us needing to connect
  var guilds = [Snowflake: PotentialConnection]()

  /// Object of completion handlers mapped by guildId
  var handlers = [Snowflake: (VoiceConnection) -> ()]()

  // MARK: Functions

  /**
   Creates VoiceConnection and hands it data/Moves channels

   - parameter guildId: Guild that we're connecting to
   - parameter endpoint: URL for voice server
   - parameter identify: Identify payload to send once we're ready
  */
  func join(_ guildId: Snowflake, _ gatewayUrl: String, _ identify: Payload) {
    guard self.connections[guildId] == nil else {
      self.connections[guildId]!.moveChannels(
        gatewayUrl,
        identify,
        self.handlers[guildId]!
      )
      self.handlers.removeValue(forKey: guildId)
      return
    }

    let voiceConnection = VoiceConnection(
      gatewayUrl,
      guildId,
      identify,
      self.handlers[guildId]!
    )
    self.connections[guildId] = voiceConnection
    voiceConnection.start()
    self.handlers.removeValue(forKey: guildId)
  }

  /**
   Used to close VoiceConnection

   - parameter guildId: Guild to leave from
  */
  func leave(_ guildId: Snowflake) {
    guard let connection = self.connections[guildId] else {
      return
    }

    connection.stop()
    self.connections.removeValue(forKey: guildId)
    self.guilds.removeValue(forKey: guildId)
  }

}
  
/// Used to store potential connection info
struct PotentialConnection {
  
  // MARK: Properties
  
  /// id of potential voice channel
  let channelId: Snowflake
    
  /// id of bot user joining
  let userId: Snowflake
    
  /// id of potential session
  let sessionId: String
    
}
  
#endif
