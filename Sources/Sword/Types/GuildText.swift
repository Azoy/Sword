//
//  GuildChannel.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// GuildChannel Type
public class GuildText: GuildChannel, TextChannel, Updatable {

  // MARK: Properties

  /// Parent class
  public internal(set) weak var sword: Sword?

  /// Channel Category this channel belongs to
  public var category: GuildCategory? {
    guard let parentId = parentId else {
      return nil
    }
    
    return guild?.channels[parentId] as? GuildCategory
  }
  
  /// Guild object for this channel
  public var guild: Guild? {
    return sword?.getGuild(for: id)
  }

  /// ID of the channel
  public let id: ChannelID

  /// Whether or not this channel is NSFW
  public let isNsfw: Bool

  /// Last message sent's ID
  public let lastMessageId: MessageID?

  /// Last Pin's timestamp
  public let lastPinTimestamp: Date?

  /// Name of channel
  public let name: String?
  
  /// Parent Category ID of this channel
  public let parentId: ChannelID?
  
  /// Array of Overwrite strcuts for channel
  public internal(set) var permissionOverwrites = [OverwriteID: Overwrite]()

  /// Position of channel
  public let position: Int?

  /// Topic of the channel
  public let topic: String?

  /// Indicates what type of channel this is (.guildText or .guildVoice)
  public let type = ChannelType.guildText

  // MARK: Initializer

  /**
   Creates a GuildText structure

   - parameter sword: Parent class
   - parameter json: JSON represented as a dictionary
  */
  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword
    
    self.id = ChannelID(json["id"] as! String)!
    
    self.lastMessageId = MessageID(json["last_message_id"] as? String)

    if let lastPinTimestamp = json["last_pin_timestamp"] as? String {
      self.lastPinTimestamp = lastPinTimestamp.date
    }else {
      self.lastPinTimestamp = nil
    }

    let name = json["name"] as? String
    self.name = name
    
    if let isNsfw = json["nsfw"] as? Bool {
      self.isNsfw = isNsfw
    }else if let name = name {
      self.isNsfw = name == "nsfw" || name.hasPrefix("nsfw-")
    }else {
      self.isNsfw = false
    }

    self.parentId = ChannelID(json["parent_id"] as? String)
    
    if let overwrites = json["permission_overwrites"] as? [[String: Any]] {
      for overwrite in overwrites {
        let overwrite = Overwrite(overwrite)
        self.permissionOverwrites[overwrite.id] = overwrite
      }
    }

    self.position = json["position"] as? Int
    self.topic = json["topic"] as? String
  }

  // MARK: Functions

  func update(_ json: [String : Any]) {
  }
  
  /**
   Creates a webhook for this channel

   #### Options Params ####

   - **name**: The name of the webhook
   - **avatar**: The avatar string to assign this webhook in base64

   - parameter options: Preconfigured options to create this webhook with
  */
  public func createWebhook(
    with options: [String: String] = [:],
    then completion: ((Webhook?, RequestError?) -> ())? = nil
  ) {
    guard self.type != .guildVoice else { return }
    self.sword?.createWebhook(for: self.id, with: options, then: completion)
  }

  /**
   Deletes all reactions from message

   - parameter messageId: Message to delete all reactions from
  */
  public func deleteReactions(
    from messageId: MessageID,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    guard self.type != .guildVoice else { return }
    self.sword?.deleteReactions(from: messageId, in: self.id, then: completion)
  }

  /// Gets this channel's webhooks
  public func getWebhooks(
    then completion: @escaping ([Webhook]?, RequestError?) -> ()
  ) {
    guard self.type != .guildVoice else { return }
    self.sword?.getWebhooks(from: self.id, then: completion)
  }

}

/// Permission Overwrite Type
public struct Overwrite {

  // MARK: Properties

  /// Allowed permissions number
  public let allow: Int

  /// Denied permissions number
  public let deny: Int

  /// ID of overwrite
  public let id: OverwriteID

  /// Either "role" or "member"
  public let type: String

  // MARK: Initializer

  /**
   Creates Overwrite structure

   - parameter json: JSON representable as a dictionary
  */
  init(_ json: [String: Any]) {
    self.allow = json["allow"] as! Int
    self.deny = json["deny"] as! Int
    self.id = OverwriteID(json["id"] as! String)!
    self.type = json["type"] as! String
  }

}
