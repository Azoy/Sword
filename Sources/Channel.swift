import Foundation

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

  public func add(reaction: String, to messageId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword.requester.request(self.sword.endpoints.createReaction(self.id, messageId, reaction), method: "PUT") { error, data in
      if error == nil { completion() }
    }
  }

  public func delete(message messageId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword.requester.request(self.sword.endpoints.deleteMessage(self.id, messageId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  public func delete(messages: [String], _ completion: @escaping () -> () = {_ in}) {
    self.sword.requester.request(self.sword.endpoints.bulkDeleteMessages(self.id), body: messages.createBody(), method: "POST") { error, data in
      if error == nil { completion() }
    }
  }

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

  public func deleteReactions(from messageId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword.requester.request(self.sword.endpoints.deleteAllReactions(self.id, messageId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  public func edit(message messageId: String, to content: String, _ completion: @escaping (Message?) -> () = {_ in}) {
    self.sword.requester.request(self.sword.endpoints.editMessage(self.id, messageId), body: ["content": content].createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Message(self.sword, data as! [String: Any]))
      }
    }
  }

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

public struct DMChannel {

  public let id: String
  public let recipient: User
  public let lastMessageId: String

  init(_ sword: Sword, _ json: [String: Any]) {
    self.id = json["id"] as! String
    self.recipient = User(sword, json["recipient"] as! [String: Any])
    self.lastMessageId = json["last_message_id"] as! String
  }

}
