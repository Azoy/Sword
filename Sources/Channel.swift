import Foundation

//Channel Type
public struct Channel {

  private let sword: Sword

  public let bitrate: Int?
  public let guildId: String?
  public let id: String
  public let isPrivate: Bool?
  public let lastMessageId: String?
  public let lastPinTimestamp: Date?
  public let name: String?
  public private(set) var permissionOverwrites: [Overwrite]? = []
  public let position: Int?
  public let topic: String?
  public let type: Int?
  public let userLimit: Int?

  /* Creates a Channel structure
    @param sword: Sword - Parent class to get requester from (and other properties)
    @param json: [String: Any] - JSON Data to decode into a channel structure
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

  /* Add a reaction to a message
    @param reaction: String - Either unicode or custom emoji to add to message
    @param messageId: String - Message to add reaction to
  */
  public func add(reaction: String, to messageId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword.requester.request(self.sword.endpoints.createReaction(self.id, messageId, reaction), method: "PUT") { error, data in
      if error == nil { completion() }
    }
  }

  /* Delete a message from channel
    @param messageId: String - Message to delete
  */
  public func delete(message messageId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword.requester.request(self.sword.endpoints.deleteMessage(self.id, messageId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /* Delete messages from channel
    @param messages: [String] - Array of messageIds to delete
  */
  public func delete(messages: [String], _ completion: @escaping () -> () = {_ in}) {
    self.sword.requester.request(self.sword.endpoints.bulkDeleteMessages(self.id), body: messages.createBody(), method: "POST") { error, data in
      if error == nil { completion() }
    }
  }

  /* Deletes a pinned message
    @param messageId: String - Message to delete from pins
  */
  public func delete(pinnedMessage messageId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword.requester.request(self.sword.endpoints.deletePinnedChannelMessage(self.id, messageId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /* Delete a reaction from a message
    @param reaction: String - Either unicode or custom emoji to delete from message
    @param messageId: String - Message to delete reaction from
    @param userId: String? - If nil, delete a message from @me : else delete a message from userId
  */
  public func delete(reaction: String, from messageId: String, by userId: String? = nil, _ completion: @escaping () -> () = {_ in}) {
    var url = ""
    if userId != nil {
      url = self.sword.endpoints.deleteUserReaction(self.id, messageId, reaction, userId!)
    }else {
      url = self.sword.endpoints.deleteOwnReaction(self.id, messageId, reaction)
    }

    self.sword.requester.request(url, method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /* Delete all reactions from message
    @param messageId: String - Message to delete reactions from
  */
  public func deleteReactions(from messageId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword.requester.request(self.sword.endpoints.deleteAllReactions(self.id, messageId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /* Edit a message's content
    @param messageId: String - Message to edit
    @param content: String - New content to make message
  */
  public func edit(message messageId: String, to content: String, _ completion: @escaping (Message?) -> () = {_ in}) {
    self.sword.requester.request(self.sword.endpoints.editMessage(self.id, messageId), body: ["content": content].createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Message(self.sword, data as! [String: Any]))
      }
    }
  }

  /* Get an array of users with reaction from message
    @param reaction: String - Either unicode or custom emoji to get from message
    @param messageId: String - Message to get reaction from
  */
  public func get(reaction: String, from messageId: String, _ completion: @escaping ([User]?) -> ()) {
    self.sword.requester.request(self.sword.endpoints.getReactions(self.id, messageId, reaction)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        var returnUsers: [User] = []
        let users = data as! [[String: Any]]
        for user in users {
          returnUsers.append(User(self.sword, user))
        }

        completion(returnUsers)
      }
    }
  }

  // Get Pinned messages
  public func getPinnedMessages(_ completion: @escaping ([Message]?) -> () = {_ in}) {
    self.sword.requester.request(self.sword.endpoints.getPinnedMessages(self.id)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        var returnMessages: [Message] = []
        let messages = data as! [[String: Any]]
        for message in messages {
          returnMessages.append(Message(self.sword, message))
        }

        completion(returnMessages)
      }
    }
  }

  /* Pin a message
    @param messageId: String - Message to pin
  */
  public func pin(_ messageId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword.requester.request(self.sword.endpoints.addPinnedChannelMessage(self.id, messageId), method: "PUT") { error, data in
      if error == nil { completion() }
    }
  }

}

//Permission Overwrite Type
public struct Overwrite {

  public let allow: Int
  public let deny: Int
  public let id: String
  public let type: String

  /* Creates an Overwrite struct
    @param json: [String: Any] - JSON Data to decode into an Overwrite struct
  */
  init(_ json: [String: Any]) {
    self.allow = json["allow"] as! Int
    self.deny = json["deny"] as! Int
    self.id = json["id"] as! String
    self.type = json["type"] as! String
  }

}

//DMChannel Type
public struct DMChannel {

  public let id: String
  public let recipient: User
  public let lastMessageId: String

  /* Creates a DMChannel struct
    @param sword: Sword - Parent class to get requester from
    @param json: [String: Any] - JSON Data to decode into a DMChannel struct
  */
  init(_ sword: Sword, _ json: [String: Any]) {
    self.id = json["id"] as! String
    self.recipient = User(sword, json["recipient"] as! [String: Any])
    self.lastMessageId = json["last_message_id"] as! String
  }

}
