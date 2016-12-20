import Foundation
import WebSockets

class WS {

  let requester: Request
  var heartbeat: Heartbeat?

  var session: WebSocket?
  let sword: Sword

  init(_ sword: Sword, _ requester: Request) {
    self.requester = requester
    self.sword = sword
  }

  func getGateway(completion: @escaping (Error?, [String: Any]?) -> Void) {
    requester.request(Endpoint.gateway.description, authorization: true) { error, data in
      if error != nil {
        completion(error, nil)
        return
      }

      guard let data = data as? [String: Any] else {
        completion(.unknown, nil)
        return
      }

      completion(nil, data)
    }
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
    let identity = Payload(op: .identify, data: ["token": self.sword.token, "properties": ["$os": "linux", "$browser": "Sword", "$device": "Sword", "$referrer": "", "$referring_domain": ""], "compress": false, "large_threshold": 50]).encode()

    try? self.session?.send(identity)
  }

  func event(_ payload: Payload) {
    let data = payload.d

    if let sequenceNumber = payload.s {
      self.heartbeat?.sequence.append(sequenceNumber)
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
