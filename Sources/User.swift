import Foundation

public struct User {

  let id: Int?
  let username: String?
  let discriminator: String?
  let avatar: String?
  let bot: Bool?
  let mfaEnabled: Bool?
  let verified: Bool?
  let email: String?

  init(_ json: [String: Any]) {
    if let id = json["id"] as? String {
      self.id = Int(id)
    }else {
      self.id = nil
    }
    if let username = json["username"] as? String {
      self.username = username
    }else {
      self.username = nil
    }
    if let discriminator = json["discriminator"] as? String {
      self.discriminator = discriminator
    }else {
      self.discriminator = nil
    }
    if let avatar = json["avatar"] as? String {
      self.avatar = avatar
    }else {
      self.avatar = nil
    }
    if let bot = json["bot"] as? Bool {
      self.bot = bot
    }else {
      self.bot = nil
    }
    if let mfaEnabled = json["mfaEnabled"] as? Bool {
      self.mfaEnabled = mfaEnabled
    }else {
      self.mfaEnabled = nil
    }
    if let verified = json["verified"] as? Bool {
      self.verified = verified
    }else {
      self.verified = nil
    }
    if let email = json["email"] as? String {
      self.email = email
    }else {
      self.email = nil
    }
  }

}
