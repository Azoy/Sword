import Foundation

//Message Type
public struct Message {

  private let sword: Sword

  public internal(set) var attachments: [Attachment] = []
  public let author: User?
  public let content: String
  public internal(set) var channel: Channel
  public let editedTimestamp: Date?
  public internal(set) var embeds: [Embed] = []
  public let id: String
  public private(set) var member: Member?
  public let mentionEveryone: Bool
  public internal(set) var mentions: [User] = []
  public internal(set) var mentionedRoles: [Role] = []
  public internal(set) var reactions: [[String: Any]] = []
  public let pinned: Bool
  public let timestamp: Date
  public let tts: Bool
  public let webhookId: String?

  /* Creates Message struct
    @param sword: Sword - Parent class to get guilds from
    @param json: [String: Any] - JSON to decode into Message struct
  */
  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword

    let attachments = json["attachments"] as! [[String: Any]]
    for attachment in attachments {
      self.attachments.append(Attachment(attachment))
    }

    if json["webhook_id"] == nil {
      self.author = User(sword, json["author"] as! [String: Any])
    }else {
      self.author = nil
    }

    self.content = json["content"] as! String

    self.channel = Channel(sword, ["id": json["channel_id"] as! String])

    if let editedTimestamp = json["edited_timestamp"] as? String {
      self.editedTimestamp = editedTimestamp.date
    }else {
      self.editedTimestamp = nil
    }

    let embeds = json["embeds"] as! [[String: Any]]
    for embed in embeds {
      self.embeds.append(Embed(embed))
    }

    self.id = json["id"] as! String

    if json["webhook_id"] == nil {
      for (_, guild) in sword.guilds {
        if guild.channels[self.channel.id] != nil {
          self.member = guild.members[self.author!.id]
          break
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

    if let reactions = json["reactions"] as? [[String: Any]] {
      self.reactions = reactions
    }
    self.pinned = json["pinned"] as! Bool
    self.timestamp = (json["timestamp"] as! String).date
    self.tts = json["tts"] as! Bool
    self.webhookId = json["webhook_id"] as? String
  }

  /* Adds a reaction to self
    @param reaction: String - Either unicode or custom emoji
  */
  public func add(reaction: String, _ completion: @escaping () -> () = {_ in}) {
    self.channel.add(reaction: reaction, to: self.id, completion)
  }

  //Deletes self
  public func delete(_ completion: @escaping () -> () = {_ in}) {
    self.channel.delete(message: self.id, completion)
  }

  /* Deletes reaction from self
    @param reaction: String - Either unicode or custom emoji reaction
    @param userId: String? - If nil, delete from self else delete from userId
  */
  public func delete(reaction: String, from userId: String? = nil, _ completion: @escaping () -> () = {_ in}) {
    self.channel.delete(reaction: reaction, from: self.id, by: userId ?? nil, completion)
  }

  // Deletes all reactions from self
  public func deleteReactions(_ completion: @escaping () -> () = {_ in}) {
    self.channel.deleteReactions(from: self.id, completion)
  }

  /* Edit self's content
    @param content: String - Content to edit from self
  */
  public func edit(to content: String, _ completion: @escaping (Message?) -> () = {_ in}) {
    self.channel.edit(message: self.id, to: content, completion)
  }

  /* Get array of users from reaction
    @param reaction: String - Either unicode or custom emoji reaction
  */
  public func get(reaction: String, _ completion: @escaping ([User]?) -> ()) {
    self.channel.get(reaction: reaction, from: self.id, completion)
  }

}

//Attachment Type
public struct Attachment {

  public let filename: String
  public let height: Int?
  public let id: String
  public let proxyUrl: String
  public let size: Int
  public let url: String
  public let width: Int?

  /* Creates an Attachment struct
    @param json: [String: Any] - JSON to decode into Attachment struct
  */
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

//Embed Type
public struct Embed {

  public let author: [String: Any]
  public let color: Int
  public let description: String?
  public let fields: [[String: Any]]?
  public let footer: [String: Any]?
  public let image: [String: Any]?
  public let provider: [String: Any]?
  public let thumbnail: [String: Any]?
  public let title: String?
  public let type: String
  public let url: String?
  public let video: [String: Any]?

  /* Creates Embed struct
    @param json: [String: Any] - JSON to decode into Embed struct
  */
  init(_ json: [String: Any]) {
    self.author = json["author"] as! [String: Any]
    self.color = json["color"] as! Int
    self.description = json["description"] as? String
    self.fields = json["fields"] as? [[String: Any]]
    self.footer = json["footer"] as? [String: Any]
    self.image = json["image"] as? [String: Any]
    self.provider = json["provider"] as? [String: Any]
    self.thumbnail = json["thumbnail"] as? [String: Any]
    self.title = json["title"] as? String
    self.type = json["type"] as! String
    self.url = json["url"] as? String
    self.video = json["video"] as? [String: Any]
  }

}
