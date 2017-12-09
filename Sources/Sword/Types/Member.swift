//
//  Member.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Member Type
public struct Member {

  // MARK: Properties

  /// Guild this member is tied to
  public internal(set) weak var guild: Guild?

  /// Whether or not this member is deaf
  public let isDeaf: Bool?

  /// Whether or not this user is muted
  public let isMuted: Bool?

  /// Date when user joined guild
  public let joinedAt: Date?

  /// Nickname of member
  public let nick: String?

  /// Permission number for this user
  public internal(set) var permissions: Int = 0

  /// The current status of this user's presence
  public internal(set) var presence: Presence?

  /// Array of role ids this member has
  public internal(set) var roles = [Role]()

  /// User struct for this member
  public let user: User

  /// Member's current voice state
  public internal(set) var voiceState: VoiceState?

  // MARK: Initializer

  /**
   Creates a Member struct

   - parameter sword: Parent class to get requester from (and otras properties)
   - parameter json: JSON representable as a dictionary
  */
  init(_ sword: Sword, _ guild: Guild, _ json: [String: Any]) {
    self.guild = guild
    self.isDeaf = json["deaf"] as? Bool

    let joinedAt = json["joined_at"] as? String
    self.joinedAt = joinedAt?.date

    self.isMuted = json["mute"] as? Bool
    self.nick = json["nick"] as? String

    let roles = (json["roles"] as! [String]).map({ Snowflake($0)! })
    for role in roles {
      self.roles.append(guild.roles[role]!)

      self.permissions |= guild.roles[role]!.permissions
    }

    self.user = User(sword, json["user"] as! [String: Any])
  }

  // MARK: Functions

  /**
   Checks if member has a certain permission

   - parameter permission: Permission to check for
  */
  public func hasPermission(_ permission: Permission) -> Bool {
    if self.user.id == self.guild!.ownerId {
      return true
    }

    if self.permissions & Permission.administrator.rawValue > 0 {
      return true
    }

    if self.permissions & permission.rawValue > 0 {
      return true
    }

    return false
  }

}

/// Structure for presences
public struct Presence {

  /// Value type for statuses
  public enum Status: String {

    /// Do not disturb status
    case dnd

    /// Away status
    case idle

    /// Invisible/Offline status
    case offline

    /// Online status
    case online
  }

  // MARK: Properties

  /// The current game this user is playing/nil if not playing a game
  public internal(set) var game: String?

  /// The current status for this user
  public internal(set) var status: Status

  // MARK: Initializers

  /// Creates a Presence structure
  init(_ json: [String: Any]) {
    if let game = json["game"] as? [String: Any] {
      self.game = game["name"] as? String
    }else {
      self.game = nil
    }
    
    self.status = Status(rawValue: json["status"] as! String)!
  }

  /**
   Creates a Presence structure

   - parameter status: Status to set to
   - parameter game: The game name to play
  */
  public init(status: Status = .online, playing game: String? = nil) {
    self.status = status
    self.game = game
  }

}
