import Foundation

extension Shard {

  func handleEvents(_ payload: Payload, _ eventName: String) {
    switch Event(rawValue: eventName)! {
      case .ready:
        self.sessionId = (payload.d as! [String: Any])["session_id"] as? String
        self.sword.user = User((payload.d as! [String: Any])["user"] as! [String: Any])
        self.sword.emit("ready", with: self.sword.user!)
        break
      case .presenceUpdate:
        let data = payload.d as! [String: Any]
        let user = User(data["user"] as! [String: Any])
        self.sword.emit("presenceUpdate", with: user.id!, ["status": data["status"] as! String, "game": data["game"]])
        break
      default:
        print(eventName)
    }
  }

}
