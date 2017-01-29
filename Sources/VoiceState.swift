public struct VoiceState {

  public let channelId: String

  public let isDeafend: Bool

  public let isMuted: Bool

  public let isSelfDeafend: Bool

  public let isSelfMuted: Bool

  public let isSuppressed: Bool

  public let sessionId: String

  init(_ json: [String: Any]) {
    self.channelId = json["channel_id"] as! String
    self.isDeafend = json["deaf"] as! Bool
    self.isMuted = json["mute"] as! Bool
    self.isSelfDeafend = json["self_deaf"] as! Bool
    self.isSelfMuted = json["self_mute"] as! Bool
    self.isSuppressed = json["suppress"] as! Bool
    self.sessionId = json["session_id"] as! String
  }

}
