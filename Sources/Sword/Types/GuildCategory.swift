//
//  Webhook.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Guild Channel Category Structure
public class GuildCategory: GuildChannel {

  /// Parent class
  public weak var sword: Sword?
  
  /// Channel Category this channel belongs to
  public var category: GuildCategory? {
    guard let parentId = parentId else {
      return nil
    }
    
    return guild?.channels[parentId] as? GuildCategory
  }
  
  /// Collection of channels this category parents mapped by channel id
  public internal(set) var channels = [Snowflake: GuildChannel]()
  
  /// The id of the channel
  public let id: Snowflake
  
  /// Guild this channel belongs to
  public var guild: Guild? {
    return sword?.getGuild(for: id)
  }
  
  /// Name of the channel
  public let name: String?
  
  /// Parent Category ID of this channel
  public let parentId: Snowflake?
  
  /// Collection of overwrites mapped by `OverwriteID`
  public internal(set) var permissionOverwrites = [Snowflake: Overwrite]()
  
  /// Position the channel is in guild
  public let position: Int?
  
  /// Indicates what type of channel this is (.guildCategory)
  public let type = ChannelType.guildCategory
  
  /**
   Creates Guild Category structure
   
   - parameter sword: The parent class
   - parameter json: The data to transform to a webhook
   */
  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword
    
    self.id = Snowflake(json["id"])!
    self.name = json["name"] as? String
    self.parentId = Snowflake(json["parent_id"])
    
    if let overwrites = json["permission_overwrites"] as? [[String: Any]] {
      for overwrite in overwrites {
        let overwrite = Overwrite(overwrite)
        self.permissionOverwrites[overwrite.id] = overwrite
      }
    }
    
    self.position = json["position"] as? Int
    
    if let guildId = Snowflake(json["guild_id"]) {
      sword.guilds[guildId]!.channels[self.id] = self
    }
  }
  
}

