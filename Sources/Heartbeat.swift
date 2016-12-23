import Foundation
import Dispatch
import WebSockets

//<3
class Heartbeat {

  let session: WebSocket

  let interval: Int
  var sequence: Int?

  var received = false

  let queue = DispatchQueue(label: "gg.azoy.sword.heartbeat", qos: .userInitiated)

  /* Creates Heartbeat
    @param ws: WebSocket - The websocket to send heartbeat payloads to
    @param interval: Int - The interval at which Discord wants heartbeats
  */
  init(_ ws: WebSocket, interval: Int) {
    self.session = ws
    self.interval = interval
  }

  // Starts/Sends heartbeat payload
  func send() {
    let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(self.interval)

    queue.asyncAfter(deadline: deadline) {
      let heartbeat = Payload(op: .heartbeat, data: self.sequence ?? NSNull()).encode()

      try? self.session.send(heartbeat)
      self.received = false

      self.send()
    }
  }

}
