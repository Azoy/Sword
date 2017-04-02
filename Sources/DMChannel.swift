//
//  DMChannel.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// DMChannel Type
public struct DMChannel: Channel {

  // MARK: Properties

  /// Parent class
  public internal(set) weak var sword: Sword?

  /// ID of DM
  public let id: String

  /// The recipient of this DM
  public internal(set) var recipients = [User]()

  /// The last message's ID
  public let lastMessageId: String?

  /// Collection of messages mapped by message id
  public internal(set) var messages = [String: Message]() {
    didSet {
      if messages.count > self.sword!.options.messageLimit {
        let firstPair = messages.first!
        messages.removeValue(forKey: firstPair.0)
      }
    }
  }

  // MARK: Initializer

  /**
   Creates a DMChannel struct

   - parameter sword: Parent class
   - parameter json: JSON representable as a dictionary
   */
  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword

    self.id = json["id"] as! String

    let recipients = json["recipients"] as! [[String: Any]]
    for recipient in recipients {
      self.recipients.append(User(sword, recipient))
    }

    self.lastMessageId = json["last_message_id"] as? String
  }

}
