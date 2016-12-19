import Foundation

public class Sword {

  let token: String

  let requester: Request
  let endpoint: Endpoint

  var gatewayUrl: String?

  public init(token: String) {
    self.token = token
    self.requester = Request(token)
    self.endpoint = Endpoint()
  }

  public func connect() {
    getGateway() { error, gatewayUrl in
      if error != nil {
        print(error!)
        sleep(2)
        self.connect()
      }else {
        self.gatewayUrl = gatewayUrl!
        print(self.gatewayUrl!)
      }
    }
  }

}
