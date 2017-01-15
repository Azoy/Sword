import Foundation

final class VoiceManager {

  var connections: [String: VoiceConnection] = [:]

  var guilds: [String: [String: String]] = [:]

  func join(_ guildId: String, _ endpoint: String, _ identify: String) {
    let voiceConnection = VoiceConnection(endpoint, guildId)
    self.connections[guildId] = voiceConnection
    voiceConnection.startWS(identify)
  }

}
