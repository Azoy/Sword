//
//  Events.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Represents Discord events
public enum Event: String {
  /// Indicates that a channel was created
  case channelCreate = "CHANNEL_CREATE"
  
  /// Indicates a guild was unavailable, but is now available
  case guildAvailable
  
  /// Indicates that the bot has joined a guild
  case guildCreate = "GUILD_CREATE"
  
  /// Indicates that a message was created
  case messageCreate = "MESSAGE_CREATE"
  
  /// Indicates that a user's presence has been updated
  case presenceUpdate = "PRESENCE_UPDATE"
  
  /// Initial state information
  case ready = "READY"
  
  /// Indicates that we successfully resumed the session
  case resumed = "RESUMED"
  
  /// Indicates that a user has started typing in a channel
  case typingStart = "TYPING_START"
}
