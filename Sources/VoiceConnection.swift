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

  var secret: [UInt8] = []

  var sequence = 0

  var session: WebSocket?

  var udpClient: UDPClient?

  let udpUrl = ""

  init(_ endpoint: String, _ guildId: String) {
    let endpoint = endpoint.components(separatedBy: ":")
    self.endpoint = endpoint[0]
    self.guildId = guildId
    self.port = Int(endpoint[1])!
  }

  deinit {
    self.close()
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

    guard let client = try? UDPClient(address: address) else {
      self.close()

      return
    }

    self.udpClient = client

    do {
      try client.send(bytes: [UInt8](repeating: 0x00, count: 70))
      let (data, _) = try client.receive(maxBytes: 70)

      self.selectProtocol(data)
    } catch {
      self.close()
    }
  }

  func close() {
    self.session = nil
    self.heartbeat = nil
    self.isConnected = false
    self.udpClient = nil
  }

  func selectProtocol(_ bytes: [UInt8]) {
    let localIp = String(data: Data(bytes: bytes.dropLast(2)), encoding: .utf8)!
    let localPort = Int(bytes[68]) + (Int(bytes[69]) << 8)

    let payload = Payload(voiceOP: .selectProtocol, data: ["protocol": "udp", "data": ["address": localIp, "port": localPort, "mode": "xsalsa20_poly1305"]]).encode()

    try? self.session?.send(payload)
  }

  func handleWSPayload(_ payload: Payload) {
    guard payload.t != nil else {

      guard let voiceOP = VoiceOPCode(rawValue: payload.op) else { return }

      let data = payload.d as! [String: Any]

      switch voiceOP {
        case .ready:

          self.heartbeat = Heartbeat(self.session!, "heartbeat.voiceconnection.\(self.guildId)", interval: data["heartbeat_interval"] as! Int)
          self.heartbeat?.send()

          self.startUDPSocket(data["port"] as! Int)

          break
        case .sessionDescription:
          break
        default:
          break
      }

      return
    }

    //Handle other events
  }

}
