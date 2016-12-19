import Foundation

public struct Sword {

  let token: String

  let requester: Request

  public init(token: String) {
    self.token = token
    self.requester = Request(token)
  }

  public func connect() {
    getGateway()
  }

}
