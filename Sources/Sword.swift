import Foundation

public class Sword {

  let token: String

  let requester: Request
  var shards: [Shard] = []
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

  func getGateway(completion: @escaping (Error?, [String: Any]?) -> Void) {
    self.requester.request(Endpoint.gateway.description, authorization: true) { error, data in
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

  public func connect() {
    self.getGateway() { error, data in
      if error != nil {
        print(error!)
        sleep(2)
        self.connect()
      }else {
        self.gatewayUrl = "\(data!["url"]!)/?encoding=json&v=6"
        self.shardCount = data!["shards"] as? Int

        for id in 0..<self.shardCount! {
          let shard = Shard(self, id, self.shardCount!)
          self.shards.append(shard)
          shard.startWS(self.gatewayUrl!)
        }

      }
    }
  }

  public func editStatus(to status: String, playing game: [String: Any]? = nil) {
    guard self.shards.count > 0 else { return }
    var data: [String: Any] = ["afk": status == "idle", "game": NSNull(), "since": status == "idle" ? Date().milliseconds : 0, "status": status]

    if game != nil {
      data["game"] = game
    }

    let payload = Payload(op: .statusUpdate, data: data).encode()

    for shard in self.shards {
      shard.send(payload)
    }
  }

}
