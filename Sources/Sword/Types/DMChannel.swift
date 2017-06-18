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
  public let id: ChannelID

  /// The recipient of this DM
  public internal(set) var recipient: User

  /// The last message's ID
  public let lastMessageId: MessageID?

  // MARK: Initializer

  /**
   Creates a DMChannel struct

   - parameter sword: Parent class
   - parameter json: JSON representable as a dictionary
   */
  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword

    self.id = Snowflake(json["id"] as! String)!

    let recipients = json["recipients"] as! [[String: Any]]
    self.recipient = User(sword, recipients[0])

    self.lastMessageId = Snowflake(json["last_message_id"] as? String)
  }

}
