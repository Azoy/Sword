import Foundation
import WebSockets

extension Sword {

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

  func startWS() {
    try? WebSocket.connect(to: gatewayUrl!) { ws in
      print("Connected to \(self.gatewayUrl!)")

      self.session = ws

      ws.onText = { ws, text in
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
    let identity: [String: Any] = ["token": self.token, "properties": ["$os": "linux", "$browser": "Sword", "$device": "Sword", "$referrer": "", "$referring_domain": ""], "compress": true, "large_threshold": 50, "shard": [1, 1]]

    let data = try? JSONSerialization.data(withJSONObject: identity, options: [])

    try? self.session?.send(String(data: data!, encoding: .utf8)!)
  }

  func event(_ packet: [String: Any]) {
    guard let eventName = packet["t"] as? String else {
      switch packet["op"] as! Int {
        case OPCode.hello.rawValue:
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
