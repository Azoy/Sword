import Foundation
import Dispatch
import WebSockets
import Socks

final class VoiceConnection {

  let gatewayUrl: String

  let guildId: String

  var heartbeat: Heartbeat?

  var isConnected = false

  var session: WebSocket?

  let udpUrl = ""

  init(_ gatewayUrl: String, _ guildId: String) {
    self.gatewayUrl = gatewayUrl
    self.guildId = guildId
  }

  func startWS(_ identify: String) {

    try? WebSocket.connect(to: self.gatewayUrl) { ws in
      self.session = ws
      self.isConnected = true

      try? ws.send(identify)

      ws.onText = { ws, text in
        self.handleWSPayload(Payload(with: text))
      }
    }

  }

  func handleWSPayload(_ payload: Payload) {
    print(payload)

    guard payload.t != nil else {

      switch VoiceOPCode(rawValue: payload.op)! {
        case .ready:
          print(payload.d)
          self.heartbeat = Heartbeat(self.session!, "heartbeat.voiceconnection.\(self.guildId)", interval: (payload.d as! [String: Any])["heartbeat_interval"] as! Int)
          self.heartbeat?.send()
          break
        default:
          break
      }

      return
    }

    //Handle other events
  }

}
