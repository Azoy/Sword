import Foundation

//Member Type
public struct Member {

  private let sword: Sword

  public let deaf: Bool
  public let joinedAt: Date
  public let mute: Bool
  public let nick: String?
  public internal(set) var roles: [String] = []
  public let user: User

  /* Creates a Member struct
    @param sword: Sword - Parent class to get requester from (and otras properties)
    @param json: [String: Any] - JSON to decode into Member struct
  */
  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword

    self.deaf = json["deaf"] as! Bool

    let joinedAt = json["joined_at"] as! String
    self.joinedAt = joinedAt.date

    self.mute = json["mute"] as! Bool
    self.nick = json["nick"] as? String

    let roles = json["roles"] as! [String]
    for role in roles {
      self.roles.append(role)
    }

    self.user = User(self.sword, json["user"] as! [String: Any])
  }

}
