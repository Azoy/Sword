import Foundation

public struct Message {

  private let sword: Sword

  public internal(set) var attachments: [Attachment] = []
  public let author: User?
  public let content: String
  public let channelId: String
  public let editedTimestamp: Date?
  public internal(set) var embeds: [Embed] = []
  public let id: String
  public let member: Member?
  public let mentionEveryone: Bool
  public internal(set) var mentions: [User] = []
  public internal(set) var mentionedRoles: [Role] = []
  public internal(set) var reactions: [[String: Any]] = []
  public let pinned: Bool
  public let timestamp: Date
  public let tts: Bool
  public let webhookId: String?

  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword

    let attachments = json["attachments"] as! [[String: Any]]
    for attachment in attachments {
      self.attachments.append(Attachment(attachment))
    }

    if let webhookId = json["webhook_id"] as? NSNull {
      self.author = User(sword, json["author"] as! [String: Any])
    }else {
      self.author = nil
    }

    self.content = json["content"] as! String
    self.channelId = json["channel_id"] as! String

    if let editedTimestamp = json["edited_timestamp"] as? String {
      self.editedTimestamp = editedTimestamp.date
    }

    let embeds = json["embeds"] as! [[String: Any]]
    for embed in embeds {
      self.embeds.append(Embed(embed))
    }

    self.id = json["id"] as! String

    if let webhookId = json["webhook_id"] as? NSNull {
      for (guildId, guild) in sword.guilds {
        if guild.channels[self.channelId] != nil {
          self.member = guild.members[self.author.id]
        }
      }
    }else {
      self.member = nil
    }

    self.mentionEveryone = json["mention_everyone"] as! Bool

    let mentions = json["mentions"] as! [[String: Any]]
    for mention in mentions {
      self.mentions.append(User(sword, mention))
    }

    let mentionedRoles = json["mention_roles"] as! [[String: Any]]
    for mentionedRole in mentionedRoles {
      self.mentionedRoles.append(Role(mentionedRole))
    }

    self.reactions = json["reactions"] as! [[String: Any]]
    self.pinned = json["pinned"] as! Bool
    self.timestamp = (json["timestamp"] as! String).date
    self.tts = json["tts"] as! Bool
    self.webhookId = json["webhook_id"] as? String
  }

}

public struct Attachment {

  public let filename: String
  public let height: Int?
  public let id: String
  public let proxyUrl: String
  public let size: Int
  public let url: String
  public let width: Int?

  init(_ json: [String: Any]) {
    self.filename = json["filename"] as! String
    self.height = json["height"] as? Int
    self.id = json["id"] as! String
    self.proxyUrl = json["proxy_url"] as! String
    self.size = json["size"] as! Int
    self.url = json["url"] as! String
    self.width = json["width"] as? Int
  }

}

public struct Embed {

  public let author: [String: Any]
  public let color: Int
  public let description: String
  public let fields: [[String: Any]]
  public let footer: [String: Any]
  public let image: [String: Any]
  public let provider: [String: Any]
  public let thumbnail: [String: Any]
  public let title: String
  public let type: String
  public let url: String
  public let video: [String: Any]

  init(_ json: [String: Any]) {
    self.author = json["author"] as! [String: Any]
    self.color = json["color"] as! Int
    self.description = json["description"] as! String
    self.fields = json["fields"] as! [[String: Any]]
    self.footer = json["footer"] as! [String: Any]
    self.image = json["image"] as! [String: Any]
    self.provider = json["provider"] as! [String: Any]
    self.thumbnail = json["thumbnail"] as! [String: Any]
    self.title = json["title"] as! String
    self.type = json["type"] as! String
    self.url = json["url"] as! String
    self.video = json["video"] as! [String: Any]
  }

}
