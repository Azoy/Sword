//
//  Events.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Represents Discord events
public enum Event: String {
  /// Indicates that a guild is now available
  case guildCreate = "GUILD_CREATE"
  
  /// Initial state information
  case ready = "READY"
  
  /// Indicates that we successfully resumed the session
  case resumed = "RESUMED"
}
