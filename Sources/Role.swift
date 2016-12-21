import Foundation

public struct Role {

  public let color: Int
  public let id: String
  public let hoist: Bool
  public let managed: Bool
  public let mentionable: Bool
  public let name: String
  public let permissions: Int
  public let position: Int

  init(_ json: [String: Any]) {
    self.color = json["color"] as! Int
    self.id = json["id"] as! String
    self.hoist = json["hoist"] as! Bool
    self.managed = json["managed"] as! Bool
    self.mentionable = json["mentionable"] as! Bool
    self.name = json["name"] as! String
    self.permissions = json["permissions"] as! Int
    self.position = json["position"] as! Int
  }

}
