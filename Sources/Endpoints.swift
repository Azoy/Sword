import Foundation

struct Endpoints {

  let baseUrl = "https://discordapp.com/api"

  var gateway: String {
    return self.baseUrl + "/gateway/bot"
  }

  func createMessage(_ channelId: String) -> String {
    return self.baseUrl + "/channels/\(channelId)/messages"
  }

}
