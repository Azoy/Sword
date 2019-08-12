//
//  Message.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Message Type
public struct Message {
  
  // MARK: Properties

  /// Array of Attachment structs that was sent with the message
  public internal(set) var attachments = [Attachment]()

  /// User struct of the author (not returned if webhook)
  public let author: User?

  /// Content of the message
  public let content: String

  /// Channel struct of the message
  public let channel: TextChannel

  /// If message was edited, this is the time it happened
  public let editedTimestamp: Date?

  /// Array of embeds sent with message
  public internal(set) var embeds = [Embed]()

  /// Message ID
  public let id: Snowflake

  /// Whether or not this message mentioned everyone
  public let isEveryoneMentioned: Bool

  /// Whether or not this message is pinned in it's channel
  public let isPinned: Bool

  /// Whether or not this messaged was ttsed
  public let isTts: Bool

  /// Member struct for message
  public internal(set) var member: Member?

  /// Array of Users that were mentioned
  public internal(set) var mentions = [User]()

  /// Array of Roles that were mentioned
  public internal(set) var mentionedRoles = [Snowflake]()

  /// Used to validate a message was sent
  public let nonce: Snowflake?

  /// Array of reactions with message
  public internal(set) var reactions = [[String: Any]]()

  /// Time when message was sent
  public let timestamp: Date
  
  /// Determines what type of message was sent
  public let type: Type
  
  /// If message was sent by webhook, this is that webhook's ID
  public let webhookId: Snowflake?

  // MARK: Initializer

  /**
   Creates Message struct

   - parameter sword: Parent class to get guilds from
   - parameter json: JSON representable as a dictionary
  */
  init(_ sword: Sword, _ json: [String: Any]) {
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

    self.channel = sword.getChannel(for: Snowflake(json["channel_id"])!)! as! TextChannel

    if let editedTimestamp = json["edited_timestamp"] as? String {
      self.editedTimestamp = editedTimestamp.date
    }else {
      self.editedTimestamp = nil
    }

    let embeds = json["embeds"] as! [[String: Any]]
    for embed in embeds {
      self.embeds.append(Embed(embed))
    }

    self.id = Snowflake(json["id"])!

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

    self.isEveryoneMentioned = json["mention_everyone"] as! Bool

    let mentions = json["mentions"] as! [[String: Any]]
    for mention in mentions {
      self.mentions.append(User(sword, mention))
    }

    self.mentionedRoles = (
      json["mention_roles"] as! [String]
    ).map { Snowflake($0)! }

    self.nonce = Snowflake(json["nonce"])

    if let reactions = json["reactions"] as? [[String: Any]] {
      self.reactions = reactions
    }
    self.isPinned = json["pinned"] as! Bool
    self.timestamp = (json["timestamp"] as! String).date
    self.isTts = json["tts"] as! Bool
    
    if let type = json["type"] as? Int {
      self.type = Type(rawValue: type)!
    }else {
      self.type = Type(rawValue: 0)!
    }
    
    self.webhookId = Snowflake(json["webhook_id"])
  }

  // MARK: Functions

  /**
   Adds a reaction to self

   - parameter reaction: Either unicode or custom emoji to add to this message
  */
  public func addReaction(
    _ reaction: String,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.channel.addReaction(reaction, to: self.id, then: completion)
  }

  /// Deletes self
  public func delete(then completion: ((RequestError?) -> ())? = nil) {
    self.channel.deleteMessage(self.id, then: completion)
  }

  /**
   Deletes reaction from self

   - parameter reaction: Either unicode or custom emoji reaction to remove
   - parameter userId: If nil, delete from self else delete from userId
  */
  public func deleteReaction(
    _ reaction: String,
    from userId: Snowflake? = nil,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.channel.deleteReaction(
      reaction,
      from: self.id,
      by: userId ?? nil,
      then: completion
    )
  }

  /// Deletes all reactions from self
  public func deleteReactions(then completion: ((RequestError?) -> ())? = nil) {
    guard let channel = self.channel as? GuildText else {
      completion?(nil)
      return
    }

    channel.deleteReactions(from: self.id, then: completion)
  }

  /**
   Edit self's content

   - parameter content: Content to edit from self
  */
  public func edit(
    with options: [String: Any],
    then completion: ((Message?, RequestError?) -> ())? = nil
  ) {
    self.channel.editMessage(self.id, with: options, then: completion)
  }

  /**
   Get array of users from reaction

   - parameter reaction: Either unicode or custom emoji reaction to get users from
  */
  public func getReaction(
    _ reaction: String,
    then completion: @escaping ([User]?, RequestError?) -> ()
  ) {
    self.channel.getReaction(reaction, from: self.id, then: completion)
  }

  /// Pins self
  public func pin(then completion: ((RequestError?) -> ())? = nil) {
    self.channel.pin(self.id, then: completion)
  }

  /**
   Replies to a channel
   
   - parameter message: String to send to channel
  */
  public func reply(
    with message: String,
    then completion: ((Message?, RequestError?) -> ())? = nil
  ) {
    self.channel.send(message, then: completion)
  }
  
  /**
   Replies to a channel
   
   #### Message Options ####
   
   Refer to Discord's documentation on the message body https://discordapp.com/developers/docs/resources/channel#create-message-json-params
   
   - parameter message: Dictionary containing information on the message
  */
  public func reply(
    with message: [String: Any],
    then completion: ((Message?, RequestError?) -> ())? = nil
  ) {
    self.channel.send(message, then: completion)
  }
  
  /**
   Replies to a channel with an Embed
   
   - parameter message: Embed to send to channel
  */
  public func reply(
    with message: Embed,
    then completion: ((Message?, RequestError?) -> ())? = nil
  ) {
    self.channel.send(message, then: completion)
  }
  
}

extension Message {
  
  /// Depicts what kind of message was sent in chat
  public enum `Type`: Int {
    
    /// Regular sent message
    case `default`
    
    /// Someone was added to group message
    case recipientAdd
    
    /// Someone was removed from group message
    case recipientRemove
    
    /// Someone called the group message
    case call
    
    /// Somone changed the group's name message
    case channelNameChange
    
    /// Someone changed the group's icon message
    case channelIconChange
    
    /// Somone pinned a message in this channel message
    case channelPinnedMessage
    
    /// Someone just joined the guild message
    case guildMemberJoin
  }
  
}

/// Attachment Type
public struct Attachment {
  
  // MARK: Properties
  
  /// The filename for this Attachment
  public let filename: String
  
  /// Height of image (if image)
  public let height: Int?
  
  /// ID of attachment
  public let id: Snowflake
  
  /// The proxied URL for this attachment
  public let proxyUrl: String
  
  /// Size of the file in bytes
  public let size: Int
  
  /// The original URL of the attachment
  public let url: String
  
  /// Width of image (if image)
  public let width: Int?
  
  // MARK: Initializer
  
  /**
   Creates an Attachment struct
   
   - parameter json: JSON to decode into Attachment struct
   */
  init(_ json: [String: Any]) {
    self.filename = json["filename"] as! String
    self.height = json["height"] as? Int
    self.id = Snowflake(json["id"])!
    self.proxyUrl = json["proxy_url"] as! String
    self.size = json["size"] as! Int
    self.url = json["url"] as! String
    self.width = json["width"] as? Int
  }
  
}

/// Embed Type
public struct Embed {
  
  // MARK: Properties
  
  /// Author dictionary from embed
  public var author: Author?
  
  /// Side panel color of embed
  public var color: Int?
  
  /// Description of the embed
  public var description: String?
  
  /// Fields for the embed
  public var fields: [Field]?
  
  /// Footer dictionary from embed
  public var footer: Footer?
  
  /// Image data from embed
  public var image: Image?
  
  /// Provider from embed
  public let provider: Provider?
  
  /// Thumbnail data from embed
  public var thumbnail: Thumbnail?
  
  /// Title of the embed
  public var title: String?
  
  /// Type of embed
  public let type: String
  
  /// URL of the embed
  public var url: String?
  
  /// Video data from embed
  public let video: Video?
  
  // MARK: Initializers
  
  /// Creates an Embed Structure
  public init() {
    self.provider = nil
    self.type = "rich"
    self.video = nil
  }
  
  /**
   Creates an Embed Structure
   
   - parameter json: JSON representable as a dictionary
  */
  init(_ json: [String: Any]) {
    self.author = json.keys.contains("author")
      ? Author(json["author"] as! [String: Any]) : nil
    self.color = json["color"] as? Int
    self.description = json["description"] as? String
    
    if json.keys.contains("fields") {
      self.fields = [Field]()
      let fields = json["fields"] as! [[String: Any]]
      for field in fields {
        self.fields?.append(Field(field))
      }
    }else {
      self.fields = nil
    }
    
    self.footer = json.keys.contains("footer")
      ? Footer(json["footer"] as! [String: Any]) : nil
    self.image = json.keys.contains("image")
      ? Image(json["image"] as! [String: Any]) : nil
    self.provider = json.keys.contains("provider")
      ? Provider(json["provider"] as! [String: Any]) : nil
    self.thumbnail = json.keys.contains("thumbnail")
      ? Thumbnail(json["thumbnail"] as! [String: Any]) : nil
    self.title = json["title"] as? String
    self.type = json["type"] as! String
    self.url = json["url"] as? String
    self.video = json.keys.contains("video")
      ? Video(json["video"] as! [String: Any]) : nil
  }
  
  /**
   Adds a field to the embed
   
   - parameter name: Name to give field
   - parameter value: Text that will be displayed underneath name
   - parameter inline: Whether or not to keep this field inline with others
  */
  public mutating func addField(
    _ name: String,
    value: String,
    isInline: Bool = false
  ) {
    if self.fields == nil {
      self.fields = [Field]()
    }
    
    self.fields?.append(Field(isInline: isInline, name: name, value: value))
  }
  
  /// Converts embed to dictionary
  public func encode() -> [String: Any] {
    var embed = [String: Any]()
    
    if self.author != nil { embed["author"] = self.author!.encode() }
    if self.color != nil { embed["color"] = self.color! }
    if self.description != nil { embed["description"] = self.description! }
    if self.fields != nil { embed["fields"] = self.fields!.map { $0.encode() } }
    if self.footer != nil { embed["footer"] = self.footer!.encode() }
    if self.image != nil { embed["image"] = self.image!.encode() }
    if self.thumbnail != nil { embed["thumbnail"] = self.thumbnail!.encode() }
    if self.title != nil { embed["title"] = self.title! }
    if self.url != nil { embed["url"] = self.url! }
    
    return embed
  }
  
}

extension Embed {
  public struct Author {
    public var iconUrl: String?
    public var name: String
    public var url: String?
    
    public init(iconUrl: String? = nil, name: String, url: String? = nil) {
      self.iconUrl = iconUrl
      self.name = name
      self.url = url
    }
    
    init(_ json: [String: Any]) {
      self.iconUrl = json["icon_url"] as? String
      self.name = json["name"] as! String
      self.url = json["url"] as? String
    }
    
    func encode() -> [String: Any] {
      var author = [String: Any]()
      
      if self.iconUrl != nil { author["icon_url"] = self.iconUrl! }
      author["name"] = self.name
      if self.url != nil { author["url"] = self.url! }
      
      return author
    }
  }
  
  public struct Field {
    public var isInline: Bool
    public var name: String
    public var value: String
    
    public init(isInline: Bool = true, name: String = "", value: String = "") {
      self.isInline = isInline
      self.name = name
      self.value = value
    }
    
    init(_ json: [String: Any]) {
      self.isInline = json["inline"] as! Bool
      self.name = json["name"] as! String
      self.value = json["value"] as! String
    }
    
    func encode() -> [String: Any] {
      var field = [String: Any]()
      
      field["inline"] = self.isInline
      field["name"] = self.name
      field["value"] = self.value
      
      return field
    }
  }
  
  public struct Footer {
    public var iconUrl: String?
    public var proxyIconUrl: String?
    public var text: String
    
    public init(
      text: String,
      iconUrl: String? = nil,
      proxyIconUrl: String? = nil
    ) {
      self.text = text
      self.iconUrl = iconUrl
      self.proxyIconUrl = proxyIconUrl
    }
    
    init(_ json: [String: Any]) {
      self.iconUrl = json["icon_url"] as? String
      self.proxyIconUrl = json["proxy_icon_url"] as? String
      self.text = json["text"] as! String
    }
    
    func encode() -> [String: Any] {
      var footer = [String: Any]()
      
      footer["text"] = self.text
      if self.iconUrl != nil { footer["icon_url"] = self.iconUrl! }
      if self.proxyIconUrl != nil { footer["proxy_icon_url"] = self.proxyIconUrl! }
      
      return footer
    }
  }
  
  public struct Image {
    public var height: Int
    public var proxyUrl: String
    public var url: String
    public var width: Int
    
    public init(height: Int, proxyUrl: String, url: String, width: Int) {
      self.height = height
      self.proxyUrl = proxyUrl
      self.url = url
      self.width = width
    }
    
    init(_ json: [String: Any]) {
      self.height = json["height"] as! Int
      self.proxyUrl = json["proxy_url"] as! String
      self.url = json["url"] as! String
      self.width = json["width"] as! Int
    }
    
    func encode() -> [String: Any] {
      var image = [String: Any]()
      
      image["height"] = self.height
      image["proxy_url"] = self.proxyUrl
      image["url"] = self.url
      image["width"] = self.width
      
      return image
    }
  }
  
  public struct Provider {
    public var name: String
    public var url: String?
    
    public init(name: String, url: String? = nil) {
      self.name = name
      self.url = url
    }
    
    init(_ json: [String: Any]) {
      self.name = json["name"] as! String
      self.url = json["url"] as? String
    }
    
    func encode() -> [String: Any] {
      var provider = [String: Any]()
      
      provider["name"] = self.name
      if self.url != nil { provider["url"] = self.url! }
      
      return provider
    }
  }
  
  public struct Thumbnail {
    public var height: Int
    public var proxyUrl: String
    public var url: String
    public var width: Int
    
    public init(height: Int, proxyUrl: String, url: String, width: Int) {
      self.height = height
      self.proxyUrl = proxyUrl
      self.url = url
      self.width = width
    }
    
    init(_ json: [String: Any]) {
      self.height = json["height"] as! Int
      self.proxyUrl = json["proxy_url"] as! String
      self.url = json["url"] as! String
      self.width = json["width"] as! Int
    }
    
    func encode() -> [String: Any] {
      var thumbnail = [String: Any]()
      
      thumbnail["height"] = self.height
      thumbnail["proxy_url"] = self.proxyUrl
      thumbnail["url"] = self.url
      thumbnail["width"] = self.width
      
      return thumbnail
    }
  }
  
  public struct Video {
    public var height: Int
    public var url: String
    public var width: Int
    
    init(_ json: [String: Any]) {
      self.height = json["height"] as! Int
      self.url = json["url"] as! String
      self.width = json["width"] as! Int
    }
  }
}
