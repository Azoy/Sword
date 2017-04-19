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
  var connections = [String: VoiceConnection]()

  /// Used to determine whether or not voiceServerUpdate is us needing to connect
  var guilds = [String: [String: String]]()

  /// Object of completion handlers mapped by guildId
  var handlers = [String: (VoiceConnection) -> ()]()

  // MARK: Functions

  /**
   Creates VoiceConnection and hands it data/Moves channels

   - parameter guildId: Guild that we're connecting to
   - parameter endpoint: URL for voice server
   - parameter identify: Identify payload to send once we're ready
  */
  func join(_ guildId: String, _ endpoint: String, _ identify: String) {
    if self.connections[guildId] == nil {
      let voiceConnection = VoiceConnection(endpoint, guildId, self.handlers[guildId]!)
      self.connections[guildId] = voiceConnection
      voiceConnection.startWS(identify)
      self.handlers.removeValue(forKey: guildId)
    }else {
      self.connections[guildId]!.moveChannels(endpoint, identify, self.handlers[guildId]!)
      self.handlers.removeValue(forKey: guildId)
    }
  }

  /**
   Used to close VoiceConnection

   - parameter guildId: Guild to leave from
  */
  func leave(_ guildId: String) {
    self.connections[guildId]!.close()
    self.connections.removeValue(forKey: guildId)
    self.guilds.removeValue(forKey: guildId)
  }

}

#endif
