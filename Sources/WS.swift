import Foundation
import WebSockets

class WS {

  let requester: Request
  let endpoint = Endpoint()
  var heartbeat: Heartbeat?

  var session: WebSocket?

  init(_ requester: Request) {
    self.requester = requester
  }

  func getGateway(completion: @escaping (Error?, [String: Any]?) -> Void) {
    requester.request(endpoint.gateway, authorization: true) { error, data in
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
        print(text)
        let packet = self.getPacket(text)

        self.event(packet)
      }

      ws.onClose = { ws, _, _, _ in
        print("WS Closed")
      }
    }
  }

  func getPacket(_ text: String) -> [String: Any] {
    let packet = try? JSONSerialization.jsonObject(with: text.data(using: .utf8)!, options: .allowFragments) as! [String: Any]

    return packet!
  }

  func identify() {
    let identity: [String: Any] = ["op": OPCode.identify.rawValue, "d": ["token": self.requester.token, "properties": ["$os": "linux", "$browser": "Sword", "$device": "Sword", "$referrer": "", "$referring_domain": ""], "compress": true, "large_threshold": 50]]

    let data = try? JSONSerialization.data(withJSONObject: identity, options: [])

    try? self.session?.send(String(data: data!, encoding: .utf8)!)
  }

  func event(_ packet: [String: Any]) {
    let data = packet["d"]

    if let sequenceNumber = packet["s"] as? Int {
      self.heartbeat?.sequence.append(sequenceNumber)
    }

    guard let eventName = packet["t"] as? String else {
      switch packet["op"] as! OPCode {
        case OPCode.hello:
          self.heartbeat = Heartbeat(self.session!, interval: (data as! [String: Any])["heartbeat_interval"] as! Int)
          self.heartbeat?.start()
          self.identify()
          break
        default:
          print("Some other opcode")
      }

      return
    }

    print(eventName)
  }

}
