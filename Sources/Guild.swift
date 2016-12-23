import Foundation

public struct Guild {

  private let sword: Sword

  public let afkChannelId: String?
  public let afkTimeout: Int?
  public internal(set) var channels: [String: Channel] = [:]
  public let defaultMessageNotifications: Int
  public let embedChannelId: Int?
  public let embedEnabled: Bool?
  public internal(set) var emojis: [Emoji] = []
  public private(set) var features: [String] = []
  public let icon: String?
  public let id: String
  public let joinedAt: Date?
  public let large: Bool?
  public let memberCount: Int
  public internal(set) var members: [String: Member] = [:]
  public let mfaLevel: Int
  public let name: String
  public let ownerId: String
  public let region: String
  public internal(set) var roles: [String: Role] = [:]
  public let shard: Int
  public let splash: String?
  public let verificationLevel: Int

  init(_ sword: Sword, _ json: [String: Any], _ shard: Int) {
    self.sword = sword

    self.afkChannelId = json["afk_channel_id"] as? String
    self.afkTimeout = json["afk_timeout"] as? Int

    if let channels = json["channels"] as? [[String: Any]] {
      for channel in channels {
        self.channels[channel["id"] as! String] = Channel(sword, channel)
      }
    }

    self.defaultMessageNotifications = json["default_message_notifications"] as! Int
    self.embedChannelId = json["embed_channel_id"] as? Int
    self.embedEnabled = json["embed_enabled"] as? Bool

    if let emojis = json["emojis"] as? [[String: Any]] {
      for emoji in emojis {
        self.emojis.append(Emoji(emoji))
      }
    }

    if let features = json["features"] as? [String] {
      for feature in features {
        self.features.append(feature)
      }
    }

    self.icon = json["icon"] as? String
    self.id = json["id"] as! String

    if let joinedAt = json["joined_at"] as? String {
      self.joinedAt = joinedAt.date
    }else {
      self.joinedAt = nil
    }

    self.large = json["large"] as? Bool
    self.memberCount = json["member_count"] as! Int

    if let members = json["members"] as? [[String: Any]] {
      for member in members {
        self.members[(member["user"] as! [String: Any])["id"] as! String] = Member(sword, member)
      }
    }

    self.mfaLevel = json["mfa_level"] as! Int
    self.name = json["name"] as! String
    self.ownerId = json["owner_id"] as! String
    self.region = json["region"] as! String

    let roles = json["roles"] as! [[String: Any]]
    for role in roles {
      let role = Role(role)
      self.roles[role.id] = role
    }

    self.shard = shard
    self.splash = json["splash"] as? String
    self.verificationLevel = json["verification_level"] as! Int
  }

}

public struct UnavailableGuild {

  let id: Int
  let shard: Int
  let unavailable: Bool

  init(_ json: [String: Any], _ shard: Int) {
    self.id = Int(json["id"] as! String)!
    self.shard = shard
    self.unavailable = json["unavailable"] as! Bool
  }

}

public struct Emoji {

  public let id: String
  public let managed: Bool
  public let name: String
  public let requireColons: Bool
  public var roles: [Role] = []

  init(_ json: [String: Any]) {
    self.id = json["id"] as! String
    self.managed = json["managed"] as! Bool
    self.name = json["name"] as! String
    self.requireColons = json["require_colons"] as! Bool

    if let roles = json["roles"] as? [[String: Any]] {
      for role in roles {
        self.roles.append(Role(role))
      }
    }
  }

}
