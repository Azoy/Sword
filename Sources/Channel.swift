import Foundation

public struct Channel {

  let sword: Sword

  public let bitrate: Int?
  public let id: String
  public let isPrivate: Bool?
  public let lastMessageId: String?
  public let lastPinTimestamp: Date?
  public let name: String
  public private(set) var permissionOverwrites: [Overwrite] = []
  public let position: Int
  public let topic: String?
  public let type: Int
  public let userLimit: Int?

  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword

    self.bitrate = json["bitrate"] as? Int
    self.id = json["id"] as! String
    self.isPrivate = json["is_private"] as? Bool
    self.lastMessageId = json["last_message_id"] as? String

    if let lastPinTimestamp = json["last_pin_timestamp"] as? String {
      self.lastPinTimestamp = lastPinTimestamp.date
    }else {
      self.lastPinTimestamp = nil
    }

    self.name = json["name"] as! String

    let overwrites = json["permission_overwrites"] as! [[String: Any]]
    for overwrite in overwrites {
      self.permissionOverwrites.append(Overwrite(overwrite))
    }

    self.position = json["position"] as! Int
    self.topic = json["topic"] as? String
    self.type = json["type"] as! Int
    self.userLimit = json["user_limit"] as? Int
  }

}

public struct Overwrite {

  public let allow: Int
  public let deny: Int
  public let id: String
  public let type: String

  init(_ json: [String: Any]) {
    self.allow = json["allow"] as! Int
    self.deny = json["deny"] as! Int
    self.id = json["id"] as! String
    self.type = json["type"] as! String
  }

}
