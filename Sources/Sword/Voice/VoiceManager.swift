//
//  VoiceManager.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

#if !os(iOS)

/// Creates VoiceManager
class VoiceManager {

  // MARK: Properties

  /// Object of connections mapped by guildId
  var connections = [GuildID: VoiceConnection]()

  /// Used to determine whether or not voiceServerUpdate is us needing to connect
  var guilds = [GuildID: PotentialConnection]()

  /// Object of completion handlers mapped by guildId
  var handlers = [GuildID: (VoiceConnection) -> ()]()

  // MARK: Functions

  /**
   Creates VoiceConnection and hands it data/Moves channels

   - parameter guildId: Guild that we're connecting to
   - parameter endpoint: URL for voice server
   - parameter identify: Identify payload to send once we're ready
  */
  func join(_ guildId: GuildID, _ gatewayUrl: String, _ identify: String) {
    guard self.connections[guildId] == nil else {
      self.connections[guildId]!.moveChannels(gatewayUrl, identify, self.handlers[guildId]!)
      self.handlers.removeValue(forKey: guildId)
      return
    }

    let voiceConnection = VoiceConnection(gatewayUrl, guildId, self.handlers[guildId]!)
    voiceConnection.identify = identify
    self.connections[guildId] = voiceConnection
    voiceConnection.start()
    self.handlers.removeValue(forKey: guildId)
  }

  /**
   Used to close VoiceConnection

   - parameter guildId: Guild to leave from
  */
  func leave(_ guildId: GuildID) {
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
  let channelId: ChannelID
    
  /// id of bot user joining
  let userId: UserID
    
  /// id of potential session
  let sessionId: String
    
}
  
#endif
