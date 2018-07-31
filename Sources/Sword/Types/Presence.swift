//
//  Presence.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation

public struct Presence: Codable, _SwordChild {
  public internal(set) weak var sword: Sword?
  
  public let activity: Activity?
  
  public var guild: Guild? {
    return sword?.guilds[guildId]
  }
  
  public let guildId: Snowflake
  public let roleIds: [Snowflake]
  
  public var roles: [Role]? {
    guard let guild = guild else {
      return nil
    }
    
    let roles = guild.roles
    return roles.filter {
      roleIds.contains($0.id)
    }
  }
  
  public let status: Status
  public let user: User
  
  enum CodingKeys: String, CodingKey {
    case activity = "game"
    case guildId = "guild_id"
    case roleIds = "roles"
    case status
    case user
  }
  
  /*
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
  }
 */
}

extension Presence {
  public struct Activity: Codable {
    public let applicationId: Snowflake?
    public let assets: Assets?
    public let details: String?
    public let name: String
    public let party: Party?
    public let state: String?
    public let timestamps: Timestamps?
    public let type: Kind
    public let url: URL?
    
    enum CodingKeys: String, CodingKey {
      case applicationId = "application_id"
      case assets
      case details
      case name
      case party
      case state
      case timestamps
      case type
      case url
    }
  }
  
  public enum Status: String, Codable, CaseIterable {
    case dnd
    case idle
    case offline
    case online
  }
}

extension Presence.Activity {
  public struct Assets: Codable {
    public let large: Image?
    public let small: Image?
    
    enum CodingKeys: String, CodingKey {
      case largeImage = "large_image"
      case largeText = "large_text"
      case smallImage = "small_image"
      case smallText = "small_text"
    }
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      // large image
      let largeImage = try container.decodeIfPresent(
        String.self,
        forKey: .largeImage
      )
      let largeText = try container.decodeIfPresent(
        String.self,
        forKey: .largeText
      )
      
      let large = Image(image: largeImage, text: largeText)
      
      if large.image == nil, large.text == nil {
        self.large = nil
      } else {
        self.large = large
      }
      
      // small image
      let smallImage = try container.decodeIfPresent(
        String.self,
        forKey: .smallImage
      )
      let smallText = try container.decodeIfPresent(
        String.self,
        forKey: .smallText
      )
      
      let small = Image(image: smallImage, text: smallText)
      
      if small.image == nil, small.text == nil {
        self.small = nil
      } else {
        self.small = small
      }
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(large?.image, forKey: .largeImage)
      try container.encodeIfPresent(large?.text, forKey: .largeText)
      try container.encodeIfPresent(small?.image, forKey: .smallImage)
      try container.encodeIfPresent(small?.text, forKey: .smallText)
    }
  }
  
  public enum Kind: UInt8, Codable, CaseIterable {
    case playing
    case streaming
    case listening
    case watching
  }
  
  public struct Party: Codable {
    public let currentSize: UInt16?
    public let id: String?
    public let maxSize: UInt16?
    
    enum CodingKeys: String, CodingKey {
      case id
      case size
    }
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.id = try container.decodeIfPresent(String.self, forKey: .id)
      let sizze = try container.decodeIfPresent([UInt16].self, forKey: .size)
      
      guard let size = sizze else {
        self.currentSize = nil
        self.maxSize = nil
        return
      }
      
      guard size.count == 2 else {
        self.currentSize = nil
        self.maxSize = nil
        return
      }
      
      self.currentSize = size[0]
      self.maxSize = size[1]
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(id, forKey: .id)
      
      guard let currentSize = currentSize, let maxSize = maxSize else {
        return
      }
      
      try container.encode([currentSize, maxSize], forKey: .size)
    }
  }
  
  // REMEMBER TO CHANGE DATE DECODING STRATEGY
  public struct Timestamps: Codable {
    public let end: Date?
    public let start: Date?
  }
}

extension Presence.Activity.Assets {
  public struct Image: Codable {
    public let image: String?
    public let text: String?
  }
}
