//
//  Channel.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Channel Type
public struct Channel {

  // MARK: Properties

  /// Parent class
  private weak var sword: Sword?

  /// (Voice) bitrate (in bits) for channel
  public let bitrate: Int?

  /// Guild ID that this channel belongs to
  public let guildId: String?

  /// ID of the channel
  public let id: String

  /// Whether or not this channel is DM or Guild
  public let isPrivate: Bool?

  /// (Text) Last message sent's ID
  public let lastMessageId: String?

  /// Last Pin's timestamp
  public let lastPinTimestamp: Date?

  /// Name of channel
  public let name: String?

  /// Array of Overwrite strcuts for channel
  public private(set) var permissionOverwrites: [Overwrite]? = []

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
        self.permissionOverwrites!.append(Overwrite(overwrite))
      }
    }

    self.position = json["position"] as? Int
    self.topic = json["topic"] as? String
    self.type = json["type"] as? Int
    self.userLimit = json["user_limit"] as? Int
  }

  // MARK: Functions

  /**
   Adds a reaction (unicode or custom emoji) to message

   - parameter reaction: Unicode or custom emoji reaction
   - parameter messageId: Message to add reaction to
   */
  public func add(reaction: String, to messageId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.createReaction(self.id, messageId, reaction), method: "PUT") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Creates a webhook for this channel

   - parameter options: ["name": "name here", "avatar": "img data as base64"]
   */
  public func createWebhook(with options: [String: String] = [:], _ completion: @escaping ([String: Any]?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.createWebhook(self.id), body: options.createBody(), method: "POST") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as? [String: Any])
      }
    }
  }

  /**
   Deletes a message from this channel

   - parameter messageId: Message to delete
   */
  public func delete(message messageId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.deleteMessage(self.id, messageId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Bulk deletes messages

   - parameter messages: Array of message ids to delete
   */
  public func delete(messages: [String], _ completion: @escaping () -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.bulkDeleteMessages(self.id), body: messages.createBody(), method: "POST") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Deletes a pinned message from this channel

   - parameter messageId: Pinned message to delete
   */
  public func delete(pinnedMessage messageId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.deletePinnedChannelMessage(self.id, messageId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Deletes a reaction from message by user

   - parameter reaction: Unicode or custom emoji to delete
   - parameter messageId: Message to delete reaction from
   - parameter userId: If nil, deletes bot's reaction from, else delete a reaction from user
   */
  public func delete(reaction: String, from messageId: String, by userId: String? = nil, _ completion: @escaping () -> () = {_ in}) {
    var url = ""
    if userId != nil {
      url = self.sword!.endpoints.deleteUserReaction(self.id, messageId, reaction, userId!)
    }else {
      url = self.sword!.endpoints.deleteOwnReaction(self.id, messageId, reaction)
    }

    self.sword!.requester.request(url, method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Deletes all reactions from message

   - parameter messageId: Message to delete all reactions from
   */
  public func deleteReactions(from messageId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.deleteAllReactions(self.id, messageId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Edits a message's content

   - parameter messageId: Message to edit
   - parameter content: Text to change message to
   */
  public func edit(message messageId: String, to content: String, _ completion: @escaping (Message?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.editMessage(self.id, messageId), body: ["content": content].createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Message(self.sword!, data as! [String: Any]))
      }
    }
  }

  /**
   Gets an array of users who used reaction from message

   - parameter reaction: Unicode or custom emoji to get
   - parameter messageId: Message to get reaction users from
   */
  public func get(reaction: String, from messageId: String, _ completion: @escaping ([User]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getReactions(self.id, messageId, reaction)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        var returnUsers: [User] = []
        let users = data as! [[String: Any]]
        for user in users {
          returnUsers.append(User(self.sword!, user))
        }

        completion(returnUsers)
      }
    }
  }

  /// Get Pinned messages for this channel
  public func getPinnedMessages(_ completion: @escaping ([Message]?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.getPinnedMessages(self.id)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        var returnMessages: [Message] = []
        let messages = data as! [[String: Any]]
        for message in messages {
          returnMessages.append(Message(self.sword!, message))
        }

        completion(returnMessages)
      }
    }
  }

  /// Gets this channel's webhooks
  public func getWebhooks(_ completion: @escaping ([[String: Any]]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getChannelWebhooks(self.id)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as? [[String: Any]])
      }
    }
  }

  /**
   Pins a message to this channel

   - parameter messageId: Message to pin
   */
  public func pin(_ messageId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.addPinnedChannelMessage(self.id, messageId), method: "PUT") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Sends a message to channel

   - parameter message: Message to send
  */
  public func send(_ message: String, _ completion: @escaping (Message?) -> () = {_ in}) {
    self.sword!.send(message, to: self.id) { msg in
      completion(msg)
    }
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

/// DMChannel Type
public struct DMChannel {

  // MARK: Properties

  /// ID of DM
  public let id: String

  /// The recipient of this DM
  public let recipient: User

  /// The last message's ID
  public let lastMessageId: String

  /**
   Creates a DMChannel struct

   - parameter sword: Parent class
   - parameter json: JSON representable as a dictionary
   */
  init(_ sword: Sword, _ json: [String: Any]) {
    self.id = json["id"] as! String
    self.recipient = User(sword, json["recipient"] as! [String: Any])
    self.lastMessageId = json["last_message_id"] as! String
  }

}
