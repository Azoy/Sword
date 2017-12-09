//
//  VoiceState.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Structure with user's voice state info
public struct VoiceState {

  // MARK: Properties

  /// The ID of the voice channel
  public let channelId: Snowflake

  /// Whether or not the user is server deafend
  public let isDeafend: Bool

  /// Whether or not the user is server muted
  public let isMuted: Bool

  /// Whether or not the user self deafend themselves
  public let isSelfDeafend: Bool

  /// Whether or not the user self muted themselves
  public let isSelfMuted: Bool

  /// Whether or not the bot suppressed the user
  public let isSuppressed: Bool

  /// The Session ID of the user and voice connection
  public let sessionId: String

  // MARK: Initializer

  /**
   Cretaes VoiceState structure

   - parameter json: The json data
  */
  init(_ json: [String: Any]) {
    self.channelId = Snowflake(json["channel_id"])!
    self.isDeafend = json["deaf"] as! Bool
    self.isMuted = json["mute"] as! Bool
    self.isSelfDeafend = json["self_deaf"] as! Bool
    self.isSelfMuted = json["self_mute"] as! Bool
    self.isSuppressed = json["suppress"] as! Bool
    self.sessionId = json["session_id"] as! String
  }

}
