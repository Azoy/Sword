//
//  GuildChannels.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

extension Guild {
  // Guild.Channel namespace
  public enum Channel {}
}

extension Guild.Channel {
  public class Category: GuildChannel, _SwordChild {
    public internal(set) weak var sword: Sword?
    
    public weak var guild: Guild? {
      guard let guildId = guildId else {
        return nil
      }
      
      return sword?.guilds[guildId]
    }
    
    public weak var category: Category? {
      guard let parentId = parentId else {
        return nil
      }
      
      return guild?.channels[parentId] as? Category
    }
    
    public internal(set) var guildId: Snowflake?
    public let id: Snowflake
    public let isNsfw: Bool?
    public let name: String
    public let overwrites: [Overwrite]?
    public let parentId: Snowflake?
    public let position: UInt16
    public let topic: String?
    public let type: ChannelKind
    
    public enum CodingKeys: String, CodingKey {
      case guildId = "guild_id"
      case id
      case name
      case isNsfw = "nsfw"
      case overwrites = "permission_overwrites"
      case parentId
      case position
      case topic
      case type
    }
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.sword = decoder.userInfo[Sword.decodingInfo] as? Sword
      self.guildId = try container.decodeIfPresent(
        Snowflake.self,
        forKey: .guildId
      )
      self.id = try container.decode(Snowflake.self, forKey: .id)
      self.isNsfw = try container.decodeIfPresent(Bool.self, forKey: .isNsfw)
      self.name = try container.decode(String.self, forKey: .name)
      self.overwrites = try container.decodeIfPresent(
        [Overwrite].self,
        forKey: .overwrites
      )
      self.parentId = try container.decodeIfPresent(
        Snowflake.self,
        forKey: .parentId
      )
      self.position = try container.decode(UInt16.self, forKey: .position)
      self.topic = try container.decodeIfPresent(String.self, forKey: .topic)
      self.type = try container.decode(ChannelKind.self, forKey: .type)
    }
    
    public func encode(to encoder: Encoder) throws {
      
    }
  }
}

extension Guild.Channel {
  public class Text: GuildChannel, TextChannel, _SwordChild {
    public internal(set) weak var sword: Sword?
    
    public weak var guild: Guild? {
      guard let guildId = guildId else {
        return nil
      }
      
      return sword?.guilds[guildId]
    }
    
    public weak var category: Category? {
      guard let parentId = parentId else {
        return nil
      }
      
      return guild?.channels[parentId] as? Category
    }
    
    public internal(set) var guildId: Snowflake?
    public let id: Snowflake
    public let isNsfw: Bool?
    public let lastMessageId: Snowflake?
    public let name: String
    public let overwrites: [Overwrite]?
    public let parentId: Snowflake?
    public let position: UInt16
    public let topic: String?
    public let type: ChannelKind
    
    public enum CodingKeys: String, CodingKey {
      case guildId = "guild_id"
      case id
      case isNsfw = "nsfw"
      case lastMessageId = "last_message_id"
      case name
      case overwrites = "permission_overwrites"
      case parentId
      case position
      case topic
      case type
    }
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.sword = decoder.userInfo[Sword.decodingInfo] as? Sword
      self.guildId = try container.decodeIfPresent(
        Snowflake.self,
        forKey: .guildId
      )
      self.id = try container.decode(Snowflake.self, forKey: .id)
      self.isNsfw = try container.decodeIfPresent(Bool.self, forKey: .isNsfw)
      self.lastMessageId = try container.decodeIfPresent(
        Snowflake.self,
        forKey: .lastMessageId
      )
      self.name = try container.decode(String.self, forKey: .name)
      self.overwrites = try container.decodeIfPresent(
        [Overwrite].self,
        forKey: .overwrites
      )
      self.parentId = try container.decodeIfPresent(
        Snowflake.self,
        forKey: .parentId
      )
      self.position = try container.decode(UInt16.self, forKey: .position)
      self.topic = try container.decodeIfPresent(String.self, forKey: .topic)
      self.type = try container.decode(ChannelKind.self, forKey: .type)
    }
    
    public func encode(to encoder: Encoder) throws {
      
    }
  }
}

extension Guild.Channel {
  public class Voice: GuildChannel, _SwordChild {
    public internal(set) weak var sword: Sword?
    
    public weak var guild: Guild? {
      guard let guildId = guildId else {
        return nil
      }
      
      return sword?.guilds[guildId]
    }
    
    public weak var category: Category? {
      guard let parentId = parentId else {
        return nil
      }
      
      return guild?.channels[parentId] as? Category
    }
    
    public internal(set) var guildId: Snowflake?
    public let id: Snowflake
    public let isNsfw: Bool?
    public let name: String
    public let overwrites: [Overwrite]?
    public let parentId: Snowflake?
    public let position: UInt16
    public let topic: String?
    public let type: ChannelKind
    
    public enum CodingKeys: String, CodingKey {
      case guildId = "guild_id"
      case id
      case isNsfw = "nsfw"
      case name
      case overwrites = "permission_overwrites"
      case parentId
      case position
      case topic
      case type
    }
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.sword = decoder.userInfo[Sword.decodingInfo] as? Sword
      self.guildId = try container.decodeIfPresent(
        Snowflake.self,
        forKey: .guildId
      )
      self.id = try container.decode(Snowflake.self, forKey: .id)
      self.isNsfw = try container.decodeIfPresent(Bool.self, forKey: .isNsfw)
      self.name = try container.decode(String.self, forKey: .name)
      self.overwrites = try container.decodeIfPresent(
        [Overwrite].self,
        forKey: .overwrites
      )
      self.parentId = try container.decodeIfPresent(
        Snowflake.self,
        forKey: .parentId
      )
      self.position = try container.decode(UInt16.self, forKey: .position)
      self.topic = try container.decodeIfPresent(String.self, forKey: .topic)
      self.type = try container.decode(ChannelKind.self, forKey: .type)
    }
    
    public func encode(to encoder: Encoder) throws {
      
    }
  }
}
