//
//  Channel.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

public protocol Channel: Codable {
  var id: Snowflake { get }
  var sword: Sword? { get }
  var type: ChannelKind { get }
}

public protocol GuildChannel: Channel {
  var category: Guild.Channel.Category? { get }
  var guild: Guild? { get }
  var guildId: Snowflake? { get }
  var isNsfw: Bool? { get }
  var name: String { get }
  var overwrites: [Overwrite]? { get }
  var parentId: Snowflake? { get }
  var position: UInt16 { get }
  var topic: String? { get }
}

public protocol TextChannel: Channel {
  var lastMessageId: Snowflake? { get }
}

public enum ChannelKind: UInt8, Codable {
  case guildText
  case dm
  case guildVoice
  case groupDM
  case guildCategory
}

// Internal structure to understand what channel we're decoding
struct ChannelDecoding: Decodable {
  var type: ChannelKind
}
