import Foundation

extension Shard {

  func handleEvents(_ payload: Payload, _ eventName: String) {
    let data = payload.d as! [String: Any]

    switch Event(rawValue: eventName)! {
      case .ready:
        self.sessionId = data["session_id"] as? String
        self.sword.user = User(self.sword, data["user"] as! [String: Any])
        self.sword.emit("ready", with: self.sword.user!)
        break
      case .presenceUpdate:
        let user = User(self.sword, data["user"] as! [String: Any])
        self.sword.emit("presenceUpdate", with: user.id!, ["status": data["status"] as! String, "game": data["game"]])
        break
      default:
        print(eventName)
    }
  }

}
