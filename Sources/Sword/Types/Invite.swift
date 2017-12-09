//
//  Invite.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Invite structure
public struct Invite {
  
  // MARK: Properties
  
  /// Channel who owns this invite
  public internal(set) weak var channel: GuildText?
  
  /// Invite code to join
  public let code: String
  
  /// Guild who owns this invite
  public internal(set) weak var guild: Guild?
  
  // MARK: Initializer
  
  /**
   Creates an Invite structure
   
   - parameter sword: Used to get references to channel and guild
   - parameter json: Dictionary representation of invite json
  */
  init(_ sword: Sword, _ json: [String: Any]) {
    let guild = sword.guilds[
      Snowflake((json["guild"] as! [String: Any])["id"])!
    ]
    self.guild = guild
    self.channel = guild?.channels[
      Snowflake((json["channel"] as! [String: Any])["id"])!
    ] as? GuildText
    self.code = json["code"] as! String
  }
  
}
