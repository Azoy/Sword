import Foundation

public struct Webhook {

  public weak var sword: Sword?

  public let avatar: String

  public let channelId: String

  public let guildId: String

  public let id: String

  public let name: String

  public let user: User

  public let token: String

  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword

    self.avatar = json["avatar"] as! String
    self.channelId = json["channel_id"] as! String
    self.guildId = json["guild_id"] as! String
    self.id = json["id"] as! String
    self.name = json["name"] as! String
    self.user = User(sword, json["user"] as! [String: Any])
    self.token = json["token"] as! String
  }

}
