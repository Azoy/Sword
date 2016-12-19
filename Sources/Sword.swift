import Foundation

public class Sword {

  let token: String

  let requester: Request
  let ws: WS
  let eventer = Eventer()

  var gatewayUrl: String?
  var shardCount: Int?

  public init(token: String) {
    self.token = token
    self.requester = Request(token)
    self.ws = WS(self.eventer, requester)
  }

  public func connect() {
    ws.getGateway() { error, data in
      if error != nil {
        print(error!)
        sleep(2)
        self.connect()
      }else {
        self.gatewayUrl = "\(data!["url"]!)/?encoding=json&v=6"
        self.shardCount = data!["shards"] as? Int

        self.ws.startWS(self.gatewayUrl!)
      }
    }
  }

  public func on(_ eventName: String, completion: @escaping (_ data: Any...) -> Void) {
    self.eventer.on(eventName, completion)
  }

}
