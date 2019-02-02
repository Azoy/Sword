//
//  Message.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation

public struct Message: Codable {
  public let id: Snowflake
  public let channelId: Snowflake
  public let guildId: Snowflake?
  public let author: User
  public let member: Guild.Member?
  public let content: String
  public let timestamp: Date
  public let editedTimestamp: Date?
  public let isTTS: Bool
  public let mentions: Mentions
  
  public enum CodingKeys: String, CodingKey {
    case id
    case channelId = "channel_id"
    case guildId = "guild_id"
    case author
    case member
    case content
    case timestamp
    case editedTimestamp = "edited_timestamp"
    case isTTS = "tts"
    case isMentionEveryone = "mention_everyone"
    case mentions
    case mentionedRoleIds = "mention_roles"
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(Snowflake.self, forKey: .id)
    self.channelId = try container.decode(Snowflake.self, forKey: .channelId)
    self.guildId = try container.decode(Snowflake.self, forKey: .guildId)
    self.author = try container.decode(User.self, forKey: .author)
    self.member = try container.decodeIfPresent(
      Guild.Member.self,
      forKey: .member
    )
    self.content = try container.decode(String.self, forKey: .content)
    self.timestamp = try container.decode(Date.self, forKey: .timestamp)
    self.editedTimestamp = try container.decodeIfPresent(
      Date.self,
      forKey: .editedTimestamp
    )
    self.isTTS = try container.decode(Bool.self, forKey: .isTTS)
    let isMentionEveryone = try container.decode(
      Bool.self,
      forKey: .isMentionEveryone
    )
    let mentionRoleIds = try container.decode(
      [Snowflake].self,
      forKey: .mentionedRoleIds
    )
    let mentionUsers = try container.decode([User].self, forKey: .mentions)
    self.mentions = Mentions(isMentionEveryone, mentionRoleIds, mentionUsers)
  }
  
  public func encode(to encoder: Encoder) throws {
    
  }
}

extension Message {
  public struct Mentions: Codable {
    public let isEveryone: Bool
    public let roleIds: [Snowflake]
    public let users: [User]
    
    init(_ isEveryone: Bool, _ roleIds: [Snowflake], _ users: [User]) {
      self.isEveryone = isEveryone
      self.roleIds = roleIds
      self.users = users
    }
  }
}
