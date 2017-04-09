//
//  GuildChannel.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// GuildChannel Type
public struct GuildChannel: Channel {

  // MARK: Properties

  /// Parent class
  public internal(set) weak var sword: Sword?

  /// (Voice) bitrate (in bits) for channel
  public let bitrate: Int?

  /// Guild object for this channel
  public var guild: Guild? {
    if self.guildId != nil {
      return self.sword!.guilds[self.guildId!]
    }else {
      return nil
    }
  }

  /// Guild ID that this channel belongs to
  private let guildId: String?

  /// ID of the channel
  public let id: String

  /// Whether or not this channel is DM or Guild
  public let isPrivate: Bool?

  /// (Text) Last message sent's ID
  public let lastMessageId: String?

  /// Last Pin's timestamp
  public let lastPinTimestamp: Date?

  /// Collection of messages mapped by message id
  public internal(set) var messages = [String: Message]() {
    didSet {
      if messages.count > self.sword!.options.messageLimit {
        let firstPair = messages.first!
        messages.removeValue(forKey: firstPair.0)
      }
    }
  }

  /// Name of channel
  public let name: String?

  /// Array of Overwrite strcuts for channel
  public private(set) var permissionOverwrites = [String: Overwrite]()

  /// Position of channel
  public let position: Int?

  /// (Text) Topic of the channel
  public let topic: String?

  /// 0 = Text & 2 = Voice
  public let type: Int?

  /// (Voice) User limit for voice channel
  public let userLimit: Int?

  // MARK: Initializer

  /**
   Creates a channel structure

   - parameter sword: Parent class
   - parameter json: JSON represented as a dictionary
  */
  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword

    self.bitrate = json["bitrate"] as? Int
    self.guildId = json["guild_id"] as? String
    self.id = json["id"] as! String
    self.isPrivate = json["is_private"] as? Bool
    self.lastMessageId = json["last_message_id"] as? String

    if let lastPinTimestamp = json["last_pin_timestamp"] as? String {
      self.lastPinTimestamp = lastPinTimestamp.date
    }else {
      self.lastPinTimestamp = nil
    }

    self.name = json["name"] as? String

    if let overwrites = json["permission_overwrites"] as? [[String: Any]] {
      for overwrite in overwrites {
        let overwrite = Overwrite(overwrite)
        self.permissionOverwrites[overwrite.id] = overwrite
      }
    }

    self.position = json["position"] as? Int
    self.topic = json["topic"] as? String
    self.type = json["type"] as? Int
    self.userLimit = json["user_limit"] as? Int
  }

  // MARK: Functions

  /**
   Creates a webhook for this channel

   #### Options Params ####

   - **name**: The name of the webhook
   - **avatar**: The avatar string to assign this webhook in base64

   - parameter options: Preconfigured options to create this webhook with
  */
  public func createWebhook(with options: [String: String] = [:], then completion: @escaping (Webhook?, RequestError?) -> () = {_ in}) {
    self.sword!.createWebhook(for: self.id, with: options, then: completion)
  }

  /**
   Deletes all reactions from message

   - parameter messageId: Message to delete all reactions from
  */
  public func deleteReactions(from messageId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.deleteReactions(from: messageId, in: self.id, then: completion)
  }

  /// Gets this channel's webhooks
  public func getWebhooks(then completion: @escaping ([Webhook]?, RequestError?) -> ()) {
    self.sword!.getWebhooks(from: self.id, then: completion)
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
  public let id: String

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
    self.id = json["id"] as! String
    self.type = json["type"] as! String
  }

}
