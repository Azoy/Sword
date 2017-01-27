import Foundation

class VoiceManager {

  var connections: [String: VoiceConnection] = [:]

  var guilds: [String: [String: String]] = [:]

  var handlers: [String: (VoiceConnection) -> ()] = [:]

  func join(_ guildId: String, _ endpoint: String, _ identify: String) {
    let voiceConnection = VoiceConnection(endpoint, guildId, self.handlers[guildId]!)
    self.connections[guildId] = voiceConnection
    voiceConnection.startWS(identify)
    self.handlers.removeValue(forKey: guildId)
  }

  func leave(_ guildId: String) {
    self.connections.removeValue(forKey: guildId)
    self.guilds.removeValue(forKey: guildId)
  }

}
