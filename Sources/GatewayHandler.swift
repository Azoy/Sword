import Foundation

//Gateway Handler
extension Shard {

  /* Handles Gateway events (anything that doesnt have op: 0)
    @param payload: Payload - Payload from Discord WS to get data from
  */
  func handleGateway(_ payload: Payload) {

    switch OPCode(rawValue: payload.op)! {

      //OP: 11
      case .heartbeatACK:
        self.heartbeat?.received = true
        break

      //OP: 10
      case .hello:
        self.heartbeat = Heartbeat(self.session!, interval: (payload.d as! [String: Any])["heartbeat_interval"] as! Int)
        self.heartbeat?.send()
        self.identify()
        break

      //OP: 9
      case .invalidSession:
        self.stop()
        sleep(2)
        self.startWS(self.gatewayUrl)
        break

      //OP: 7
      case .reconnect:
        var data: [String: Any] = ["token": self.sword.token, "session_id": self.sessionId!, "seq": NSNull()]
        if self.lastSeq != nil {
          data.updateValue(self.lastSeq!, forKey: "seq")
        }
        let payload = Payload(op: .resume, data: data)
        self.reconnect(payload)
        break

      //Others~~~
      default:
        break
    }

  }

}
