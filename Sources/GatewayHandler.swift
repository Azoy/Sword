import Foundation

extension Shard {

  func handleGateway(_ payload: Payload) {
    switch OPCode(rawValue: payload.op)! {
      case .hello:
        self.heartbeat = Heartbeat(self.session!, interval: (payload.d as! [String: Any])["heartbeat_interval"] as! Int)
        self.heartbeat?.send()
        self.identify()
        break
      case .reconnect:
        var data: [String: Any] = ["token": self.sword.token, "session_id": self.sessionId!, "seq": NSNull()]
        if self.lastSeq != nil {
          data.updateValue(self.lastSeq!, forKey: "seq")
        }
        let payload = Payload(op: .resume, data: data).encode()
        self.send(payload)
        break
      case .heartbeatACK:
        break
      default:
        print(payload.op)
    }
  }

}
