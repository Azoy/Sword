import Foundation

class VoiceManager {

  var connections: [String: VoiceConnection] = [:]

  var guilds: [String: [String: String]] = [:]

  var handlers: [String: (VoiceConnection) -> ()] = [:]

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

  func leave(_ guildId: String) {
    self.connections[guildId]!.close()
    self.connections.removeValue(forKey: guildId)
    self.guilds.removeValue(forKey: guildId)
  }

}
