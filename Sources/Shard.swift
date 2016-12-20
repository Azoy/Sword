import Foundation
import WebSockets

class Shard {

  let id: Int
  let shardCount: Int
  var heartbeat: Heartbeat?

  var session: WebSocket?
  let sword: Sword

  var lastSeq: Int?

  init(_ sword: Sword, id: Int, shardCount: Int) {
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
    let data = payload.d

    if let sequenceNumber = payload.s {
      self.heartbeat?.sequence.append(sequenceNumber)
      self.lastSeq = sequenceNumber
    }

    guard let eventName = payload.t else {
      switch OPCode(rawValue: payload.op)! {
        case .hello:
          self.heartbeat = Heartbeat(self.session!, interval: (data as! [String: Any])["heartbeat_interval"] as! Int)
          self.heartbeat?.send()
          self.identify()
          break
        case .heartbeatACK:
          break
        default:
          print(payload.op)
      }

      return
    }

    switch Event(rawValue: eventName)! {
      case .ready:
        self.sword.user = User((data as! [String: Any])["user"] as! [String: Any])
        self.sword.emit("ready", with: self.sword.user!)
        break
      default:
        print(eventName)
    }
  }

}
