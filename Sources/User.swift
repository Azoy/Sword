import Foundation

//User Type
public struct User {

  private let sword: Sword

  public let avatar: String?
  public let bot: Bool?
  public let discriminator: String?
  public let email: String?
  public let id: String
  public let mfaEnabled: Bool?
  public let username: String?
  public let verified: Bool?

  /* Creates User struct
    @param sword: Sword - Parent class to get properties from
    @param json: [String: Any] - JSON to decode into User struct
  */
  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword

    self.id = json["id"] as! String
    self.avatar = json["avatar"] as? String
    self.bot = json["bot"] as? Bool
    self.discriminator = json["discriminator"] as? String
    self.email = json["email"] as? String
    self.mfaEnabled = json["mfaEnabled"] as? Bool
    self.username = json["username"] as? String
    self.verified = json["verified"] as? Bool
  }

  //Gets DM for user
  public func getDM(_ completion: @escaping (DMChannel?) -> ()) {
    self.sword.requester.request(self.sword.endpoints.createDM(), body: ["recipient_id": self.id].createBody(), method: "POST") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(DMChannel(self.sword, data as! [String: Any]))
      }
    }
  }

}
