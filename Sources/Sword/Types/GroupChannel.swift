//
//  GroupChannel.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// DMChannel Type
public struct GroupChannel: Channel {

  // MARK: Properties

  /// Parent class
  public internal(set) weak var sword: Sword?

  /// ID of DM
  public let id: Snowflake

  /// The recipient of this DM
  public internal(set) var recipients = [User]()

  /// The last message's ID
  public let lastMessageId: Snowflake?

  /// Collection of messages mapped by message id
  public internal(set) var messages = [Snowflake: Message]() {
    didSet {
      if messages.count > self.sword!.options.messageLimit {
        let firstPair = messages.first!
        messages.removeValue(forKey: firstPair.0)
      }
    }
  }

  // MARK: Initializer

  /**
   Creates a GroupChannel struct

   - parameter sword: Parent class
   - parameter json: JSON representable as a dictionary
   */
  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword

    self.id = Snowflake(json["id"] as! String)!

    let recipients = json["recipients"] as! [[String: Any]]
    for recipient in recipients {
      self.recipients.append(User(sword, recipient))
    }

    self.lastMessageId = Snowflake(json["last_message_id"] as? String)
  }

}
