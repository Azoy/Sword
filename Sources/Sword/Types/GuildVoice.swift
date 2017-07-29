//
//  GuildVoice.swift
//  Sword
//
//  Created by Alejandro Alonso
//

/// Representation of a guild voice channel
public struct GuildVoice: GuildChannel {
  
  // MARK: Properties
  
  /// Parent Class
  public internal(set) weak var sword: Sword?
  
  /// Bitrate (in bits) for channel
  public let bitrate: Int?
  
  /// Guild object for this channel
  public internal(set) weak var guild: Guild?
  
  /// ID of the channel
  public let id: ChannelID
  
  /// Name of channel
  public let name: String?
  
  /// Collection of Overwrites mapped by `OverwriteID`
  public internal(set) var permissionOverwrites = [OverwriteID : Overwrite]()
  
  /// Position of channel
  public let position: Int?
  
  /// Indicates what type of channel this is (.guildVoice)
  public let type: ChannelType
  
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
    
    self.guild = sword.guilds[Snowflake(json["guild_id"] as! String)!]
    
    let name = json["name"] as? String
    self.name = name
    
    if let overwrites = json["permission_overwrites"] as? [[String: Any]] {
      for overwrite in overwrites {
        let overwrite = Overwrite(overwrite)
        self.permissionOverwrites[overwrite.id] = overwrite
      }
    }
    
    self.position = json["position"] as? Int
    self.type = ChannelType(rawValue: json["type"] as! Int)!
    self.userLimit = json["user_limit"] as? Int
  }
  
  // MARK: Functions
  
  /**
   Moves a member in this voice channel to another voice channel (if they are in it)
   
   - parameter userId: User to move
   */
  public func moveMember(_ userId: UserID, then completion: @escaping (RequestError?) -> () = {_ in}) {
    guard let guild = self.guild else { return }
    self.sword?.request(.modifyGuildMember(guild.id, userId), body: ["channel_id": self.id.description]) { data, error in
      completion(error)
    }
  }
  
}
