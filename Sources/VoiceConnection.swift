import Foundation
import Dispatch
import WebSockets
import Socks

class VoiceConnection {

  let endpoint: String

  let guildId: String

  var heartbeat: Heartbeat?

  var isConnected = false

  let port: Int

  var session: WebSocket?

  var udpClient: UDPClient?

  let udpUrl = ""

  init(_ endpoint: String, _ guildId: String) {
    let endpoint = endpoint.components(separatedBy: ":")
    self.endpoint = endpoint[0]
    self.guildId = guildId
    self.port = Int(endpoint[1])!
  }

  func startWS(_ identify: String) {

    try? WebSocket.connect(to: "wss://\(self.endpoint)") { ws in
      self.session = ws
      self.isConnected = true

      try? ws.send(identify)

      ws.onText = { ws, text in
        self.handleWSPayload(Payload(with: text))
      }

      ws.onClose = { ws, code, something, somethingagain in
        self.heartbeat = nil
        self.isConnected = false
      }
    }

  }

  func startUDPSocket(_ port: Int) {
    let address = InternetAddress(hostname: self.endpoint, port: Port(port))
    do {
      let client = try UDPClient(address: address)
      self.udpClient = client
      try client.send(bytes: [UInt8](repeating: 0x00, count: 70))
      let (data, _) = try client.receive(maxBytes: 70)
      try client.close()

      print("IP: \(String(data: Data(bytes: data.dropLast(2)), encoding: .utf8)!)")
      let portBytes = Array(data.suffix(from: data.endIndex.advanced(by: -2)))
      print("Port: \(Int(portBytes[0]) + (Int(portBytes[1]) << 8))")
    } catch {
      print("Error")
    }
  }

  func handleWSPayload(_ payload: Payload) {
    print(payload)

    guard payload.t != nil else {

      guard let voiceOP = VoiceOPCode(rawValue: payload.op) else { return }

      let data = payload.d as! [String: Any]

      switch voiceOP {
        case .ready:

          self.heartbeat = Heartbeat(self.session!, "heartbeat.voiceconnection.\(self.guildId)", interval: data["heartbeat_interval"] as! Int)
          self.heartbeat?.send()

          self.startUDPSocket(data["port"] as! Int)

          break
        default:
          break
      }

      return
    }

    //Handle other events
  }

}
