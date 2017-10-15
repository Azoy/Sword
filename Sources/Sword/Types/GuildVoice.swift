//
//  GuildVoice.swift
//  Sword
//
//  Created by Alejandro Alonso
//

/// Representation of a guild voice channel
public class GuildVoice: GuildChannel, Updatable {
  
  // MARK: Properties
  
  /// Parent Class
  public internal(set) weak var sword: Sword?
  
  /// Bitrate (in bits) for channel
  public let bitrate: Int?
  
  /// Channel Category this channel belongs to
  public var category: GuildCategory? {
    guard let parentId = parentId else {
      return nil
    }
    
    return guild?.channels[parentId] as? GuildCategory
  }
  
  /// Guild object for this channel
  public var guild: Guild? {
    return sword?.getGuild(for: id)
  }
  
  /// ID of the channel
  public let id: ChannelID
  
  /// Name of channel
  public let name: String?
  
  /// Parent Category ID of this channel
  public let parentId: ChannelID?
  
  /// Collection of Overwrites mapped by `OverwriteID`
  public internal(set) var permissionOverwrites = [OverwriteID : Overwrite]()
  
  /// Position of channel
  public let position: Int?
  
  /// Indicates what type of channel this is (.guildVoice)
  public let type = ChannelType.guildVoice
  
  /// (Voice) User limit for voice channel
  public let userLimit: Int?
  
  // MARK: Initializer
  
  /**
   Creates a GuildVoice structure
   
   - parameter sword: Parent class
   - parameter json: JSON represented as a dictionary
   */
  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword
    
    self.bitrate = json["bitrate"] as? Int
    self.id = ChannelID(json["id"] as! String)!
    
    let name = json["name"] as? String
    self.name = name
    
    self.parentId = ChannelID(json["parent_id"] as? String)
    
    if let overwrites = json["permission_overwrites"] as? [[String: Any]] {
      for overwrite in overwrites {
        let overwrite = Overwrite(overwrite)
        self.permissionOverwrites[overwrite.id] = overwrite
      }
    }
    
    self.position = json["position"] as? Int
    self.userLimit = json["user_limit"] as? Int
    
    if let guildId = GuildID(json["guild_id"] as? String) {
      sword.guilds[guildId]!.channels[self.id] = self
    }
  }
  
  // MARK: Functions
  
  func update(_ json: [String : Any]) {
  }
  
  /**
   Moves a member in this voice channel to another voice channel (if they are in it)
   
   - parameter userId: User to move
   */
  public func moveMember(
    _ userId: UserID,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    guard let guild = self.guild else { return }
    self.sword?.request(
      .modifyGuildMember(guild.id, userId),
      body: ["channel_id": self.id.description]
    ) { data, error in
      completion?(error)
    }
  }
  
}
