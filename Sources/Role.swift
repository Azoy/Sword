import Foundation

//Role Type
public struct Role {

  public let color: Int
  public let hoist: Bool
  public let id: String
  public let managed: Bool
  public let mentionable: Bool
  public let name: String
  public let permissions: Int
  public let position: Int

  /* Creates Role struct
    @param json: [String: Any] - JSON to decode into Role struct
  */
  init(_ json: [String: Any]) {
    self.color = json["color"] as! Int
    self.hoist = json["hoist"] as! Bool
    self.id = json["id"] as! String
    self.managed = json["managed"] as! Bool
    self.mentionable = json["mentionable"] as! Bool
    self.name = json["name"] as! String
    self.permissions = json["permissions"] as! Int
    self.position = json["position"] as! Int
  }

}
