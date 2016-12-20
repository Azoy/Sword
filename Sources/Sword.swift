import Foundation

public class Sword {

  let token: String

  let requester: Request
  var ws: WS?
  let eventer = Eventer()

  var gatewayUrl: String?
  var shardCount: Int?

  public var user: User?

  public init(token: String) {
    self.token = token
    self.requester = Request(token)
  }

  public func on(_ eventName: String, _ completion: @escaping (_ data: Any) -> Void) {
    self.eventer.on(eventName, completion)
  }

  public func emit(_ eventName: String, with data: Any...) {
    self.eventer.emit(eventName, with: data)
  }

  public func connect() {
    self.ws = WS(self, requester)
    self.ws!.getGateway() { error, data in
      if error != nil {
        print(error!)
        sleep(2)
        self.connect()
      }else {
        self.gatewayUrl = "\(data!["url"]!)/?encoding=json&v=6"
        self.shardCount = data!["shards"] as? Int

        self.ws!.startWS(self.gatewayUrl!)
      }
    }
  }

  public func editStatus(to status: String, playing game: [String: Any]? = nil) {
    guard self.ws != nil else { return }
    var data: [String: Any] = ["afk": status == "idle", "game": NSNull(), "since": status == "idle" ? Date().milliseconds : 0, "status": status]

    if game != nil {
      data["game"] = game
    }

    let payload = Payload(op: .statusUpdate, data: data).encode()

    self.ws!.send(payload)
  }

}
