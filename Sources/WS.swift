import Foundation
import WebSockets

extension Sword {

  func getGateway(completion: @escaping (Error?, String?) -> Void) {
    requester.request(endpoint.gateway, authorization: true) { error, data in
      if error != nil {
        completion(error, nil)
        return
      }

      guard let data = data as? [String: Any] else {
        completion(.unknown, nil)
        return
      }

      completion(nil, "\(data["url"])")
    }
  }

}
