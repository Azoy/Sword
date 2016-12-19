import Foundation

struct Endpoint  {

  let base = "https://discordapp.com/api"

  var gateway: String {
    return base + "/gateway/bot"
  }

}
