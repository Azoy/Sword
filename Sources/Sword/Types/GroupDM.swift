//
//  GroupChannel.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// GroupDM Type
public struct GroupDM: TextChannel {

  // MARK: Properties

  /// Parent class
  public internal(set) weak var sword: Sword?

  /// ID of DM
  public let id: Snowflake

  /// The recipient of this DM
  public internal(set) var recipients = [User]()

  /// The last message's ID
  public let lastMessageId: Snowflake?
  
  /// Indicates what kind of channel this is
  public let type = ChannelType.groupDM
  
  // MARK: Initializer

  /**
   Creates a GroupChannel struct

   - parameter sword: Parent class
   - parameter json: JSON representable as a dictionary
   */
  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword

    self.id = Snowflake(json["id"])!

    let recipients = json["recipients"] as! [[String: Any]]
    for recipient in recipients {
      self.recipients.append(User(sword, recipient))
    }

    self.lastMessageId = Snowflake(json["last_message_id"])
    
    sword.groups[self.id] = self
  }
  
}
