import Foundation
import WebSockets

extension Sword {

  func getGateway() {
    requester.request(Endpoint.gateway.rawValue, with: ["Authorization": "Bot \(token)"]) { error, data in
      if error == nil {
        print(error!)
        return
      }

      print(data!)
    }
  }

}
