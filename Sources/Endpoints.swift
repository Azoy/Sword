import Foundation

struct Endpoints {

  var gateway: String {
    return self.baseUrl + "/gateway/bot"
  }

  func createMessage(_ channelId: String) -> String {
    return "/channels/\(channelId)/messages"
  }

}
