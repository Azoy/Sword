import Foundation

public class Sword {

  let token: String

  let requester: Request
  let endpoint: Endpoint

  var gatewayUrl: String?
  var shardCount: Int?

  public init(token: String) {
    self.token = token
    self.requester = Request(token)
    self.endpoint = Endpoint()
  }

  public func connect() {
    getGateway() { error, data in
      if error != nil {
        print(error!)
        sleep(2)
        self.connect()
      }else {
        self.gatewayUrl = "\(data!["url"]!)/?encoding"
        self.shardCount = data!["shards"] as? Int

        self.startWS()
      }
    }
  }

}
