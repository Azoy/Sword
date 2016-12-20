import Foundation
import WebSockets

class Shard {

  let id: Int
  let shardCount: Int
  var sessionId: String?
  var heartbeat: Heartbeat?

  var session: WebSocket?
  let sword: Sword

  var lastSeq: Int?

  init(_ sword: Sword, _ id: Int, _ shardCount: Int) {
    self.sword = sword
    self.id = id
    self.shardCount = shardCount
  }

  func startWS(_ gatewayUrl: String) {
    try? WebSocket.connect(to: gatewayUrl) { ws in
      self.session = ws

      ws.onText = { ws, text in
        self.event(Payload(with: text))
      }

      ws.onClose = { ws, _, _, _ in
        print("WS Closed")
      }
    }
  }

  func send(_ text: String) {
    try? self.session!.send(text)
  }

  func identify() {
    let identity = Payload(op: .identify, data: ["token": self.sword.token, "properties": ["$os": "linux", "$browser": "Sword", "$device": "Sword", "$referrer": "", "$referring_domain": ""], "compress": false, "large_threshold": 50, "shard": [self.id, self.shardCount]]).encode()

    try? self.session?.send(identity)
  }

  func event(_ payload: Payload) {
    if let sequenceNumber = payload.s {
      self.heartbeat?.sequence.append(sequenceNumber)
      self.lastSeq = sequenceNumber
    }

    guard let eventName = payload.t else {
      self.handleGateway(payload)
      return
    }

    self.handleEvents(payload, eventName)
  }

}
