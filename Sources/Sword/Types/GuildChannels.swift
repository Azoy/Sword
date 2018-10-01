//
//  GuildChannels.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

public class GuildCategory: GuildChannel, Codable {
  public weak var sword: Sword?
  
  public weak var guild: Guild?
  
  public var category: GuildCategory?
  
  public var guildId: Snowflake?
  
  public var name: String
  
  public var overwrites: [Overwrite]
  
  public var parentId: Snowflake?
  
  public var position: UInt16
  
  public var topic: String
  
  public var id: Snowflake
  
  public var type: ChannelKind
  
  
}

public class GuildText: GuildChannel, TextChannel, Codable {
  public weak var sword: Sword?
  
  public weak var guild: Guild?
  
  public var category: GuildCategory?
  
  public var guildId: Snowflake?
  
  public var name: String
  
  public var overwrites: [Overwrite]
  
  public var parentId: Snowflake?
  
  public var position: UInt16
  
  public var topic: String
  
  public var lastMessageId: Snowflake
  
  public var id: Snowflake
  
  public var type: ChannelKind
  
  
}

public class GuildVoice: GuildChannel {
  public weak var sword: Sword?
  
  public weak var guild: Guild?
  
  public var category: GuildCategory?
  
  public var guildId: Snowflake?
  
  public var name: String
  
  public var overwrites: [Overwrite]
  
  public var parentId: Snowflake?
  
  public var position: UInt16
  
  public var topic: String
  
  public var id: Snowflake
  
  public var type: ChannelKind
  
  
}
