//
//  Guild.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Guild Type
public class Guild {

  // MARK: Properties

  /// Parent class
  public internal(set) weak var sword: Sword?

  /// ID of afk voice channel (if there is any)
  public let afkChannelId: String?

  /// AFK timeout (if there is any)
  public let afkTimeout: Int?

  /// Collection of channels mapped by channel ID
  public internal(set) var channels = [String: GuildChannel]()

  /// Default notification protocol
  public let defaultMessageNotifications: Int

  /// ID of embeddable channel
  public let embedChannelId: Int?

  /// Array of custom emojis for this guild
  public internal(set) var emojis = [Emoji]()

  /// Array of features this guild has
  public private(set) var features = [String]()

  /// Icon hash for guild
  public let icon: String?

  /// ID of guild
  public let id: String

  /// Whether or not this guild is embeddable
  public let isEmbedEnabled: Bool?

  /// Whether or not this guild is considered "large"
  public let isLarge: Bool?

  /// The date at which the bot joined the server
  public let joinedAt: Date?

  /// Amount of members this guild has
  public let memberCount: Int?

  /// Collection of members mapped by user ID
  public internal(set) var members = [String: Member]()

  /// MFA level of guild
  public let mfaLevel: Int

  /// Name of the guild
  public let name: String

  /// Owner's user ID
  public let ownerId: String

  /// Region this guild is hosted in
  public let region: String

  /// Collection of roles mapped by role ID
  public internal(set) var roles = [String: Role]()

  /// Shard ID this guild is handled by
  public let shard: Int?

  /// Splash Hash for guild
  public let splash: String?

  /// Level of verification for guild
  public let verificationLevel: Int

  /// Collection of member voice states currently in this guild
  public internal(set) var voiceStates = [String: VoiceState]()

  // MARK: Initializer

  /**
   Creates a Guild structure

   - parameter sword: Parent class
   - parameter json: JSON representable as a dictionary
   - parameter shard: Shard ID this guild is handled by
  */
  init(_ sword: Sword, _ json: [String: Any], _ shard: Int? = nil) {
    self.sword = sword

    self.id = json["id"] as! String

    self.afkChannelId = json["afk_channel_id"] as? String
    self.afkTimeout = json["afk_timeout"] as? Int

    if let channels = json["channels"] as? [[String: Any]] {
      for channel in channels {
        var returnChannel = channel
        returnChannel["guild_id"] = self.id
        let channel = GuildChannel(sword, returnChannel)
        self.channels[channel.id] = channel
      }
    }

    self.defaultMessageNotifications = json["default_message_notifications"] as! Int
    self.embedChannelId = json["embed_channel_id"] as? Int
    self.isEmbedEnabled = json["embed_enabled"] as? Bool

    if let emojis = json["emojis"] as? [[String: Any]] {
      for emoji in emojis {
        self.emojis.append(Emoji(emoji))
      }
    }

    if let features = json["features"] as? [String] {
      for feature in features {
        self.features.append(feature)
      }
    }

    self.icon = json["icon"] as? String

    if let joinedAt = json["joined_at"] as? String {
      self.joinedAt = joinedAt.date
    }else {
      self.joinedAt = nil
    }

    self.isLarge = json["large"] as? Bool
    self.memberCount = json["member_count"] as? Int

    self.mfaLevel = json["mfa_level"] as! Int
    self.name = json["name"] as! String
    self.ownerId = json["owner_id"] as! String

    self.region = json["region"] as! String

    let roles = json["roles"] as! [[String: Any]]
    for role in roles {
      let role = Role(role)
      self.roles[role.id] = role
    }

    self.shard = shard
    self.splash = json["splash"] as? String
    self.verificationLevel = json["verification_level"] as! Int

    if let members = json["members"] as? [[String: Any]] {
      for member in members {
        let member = Member(sword, self, member)
        self.members[member.user.id] = member
      }
    }

    if let presences = json["presences"] as? [[String: Any]] {
      for presence in presences {
        let userId = (presence["user"] as! [String: Any])["id"] as! String
        let presence = Presence(presence)
        self.members[userId]!.presence = presence
      }
    }

    if let voiceStates = json["voice_states"] as? [[String: Any]] {
      for voiceState in voiceStates {
        let voiceStateObjc = VoiceState(voiceState)

        self.voiceStates[voiceState["user_id"] as! String] = voiceStateObjc
        self.members[voiceState["user_id"] as! String]!.voiceState = voiceStateObjc
      }
    }
  }

  // MARK: Functions

  /**
   Bans a member from this guild

   #### Option Params ####

   - **delete-message-days**: Number of days to delete messages for (0-7)

   - parameter userId: Member to ban
   - parameter reason: Optional -- reason to ban the member (attached to audit log)
   - parameter options: Deletes messages from this user by amount of days
  */
  public func ban(_ member: String, for reason: String? = nil, with options: [String: Int] = [:], then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword?.ban(member, in: self.id, for: reason, with: options, then: completion)
  }

  /**
   Creates a channel in this guild

   #### Option Params ####

   - **name**: The name to give this channel
   - **type**: The type of channel to create
   - **bitrate**: If a voice channel, sets the bitrate for the voice channel
   - **user_limit**: If a voice channel, sets the maximum amount of users to be allowed at a time
   - **permission_overwrites**: Array of overwrite objects to give this channel

   - parameter options: Preconfigured options to give the channel on create
  */
  public func createChannel(with options: [String: Any], then completion: @escaping (GuildChannel?, RequestError?) -> () = {_ in}) {
    self.sword?.createChannel(for: self.id, with: options, then: completion)
  }

  /**
   Creates an integration for this guild

   #### Option Params ####

   - **type**: The type of integration to create
   - **id**: The id of the user's integration to link to this guild

   - parameter options: Preconfigured options for this integration
  */
  public func createIntegration(with options: [String: String], then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword?.createIntegration(for: self.id, with: options, then: completion)
  }

  /**
   Creates a guild role

   #### Option Params ####

   - **name**: The name of the role
   - **permissions**: The bitwise number to set role with
   - **color**: Integer value of RGB color
   - **hoist**: Whether or not this role is hoisted on the member list
   - **mentionable**: Whether or not this role is mentionable in chat

   - parameter options: Preset options to configure role with
  */
  public func createRole(with options: [String: Any], then completion: @escaping (Role?, RequestError?) -> () = {_ in}) {
    self.sword?.createRole(for: self.id, with: options, then: completion)
  }

  /**
   Deletes an integration from this guild

   - parameter integrationId: Integration to delete
  */
  public func deleteIntegration(_ integrationId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword?.deleteIntegration(integrationId, from: self.id, then: completion)
  }

  /**
   Deletes a role from this guild

   - parameter roleId: Role to delete
  */
  public func deleteRole(_ roleId: String, then completion: @escaping (Role?, RequestError?) -> () = {_ in}) {
    self.sword?.deleteRole(roleId, from: self.id, then: completion)
  }

  /// Deletes current guild
  public func delete(then completion: @escaping (Guild?, RequestError?) -> () = {_ in}) {
    self.sword?.deleteGuild(self.id, then: completion)
  }

  /// Gets guild's bans
  public func getBans(then completion: @escaping ([User]?, RequestError?) -> ()) {
    self.sword?.getBans(from: self.id, then: completion)
  }

  /// Gets the guild embed
  public func getEmbed(then completion: @escaping ([String: Any]?, RequestError?) -> ()) {
    self.sword?.getGuildEmbed(from: self.id, then: completion)
  }

  /// Gets guild's integrations
  public func getIntegrations(then completion: @escaping ([[String: Any]]?, RequestError?) -> ()) {
    self.sword?.getIntegrations(from: self.id, then: completion)
  }

  /// Gets guild's invites
  public func getInvites(then completion: @escaping ([[String: Any]]?, RequestError?) -> ()) {
    self.sword?.getGuildInvites(from: self.id, then: completion)
  }

  /// Gets an array of guild members
  public func getMembers(then completion: @escaping ([Member]?, RequestError?) -> ()) {
    self.sword?.getMembers(in: self.id, then: completion)
  }

  /**
   Gets number of users who would be pruned by x amount of days

   - parameter limit: Number of days to get prune count for
  */
  public func getPruneCount(for limit: Int, then completion: @escaping (Int?, RequestError?) -> ()) {
    self.sword?.getPruneCount(from: self.id, for: limit, then: completion)
  }

  /// Gets guild roles
  public func getRoles(then completion: @escaping ([Role]?, RequestError?) -> ()) {
    self.sword?.getRoles(from: self.id, then: completion)
  }

  /// Gets an array of voice regions from guild
  public func getVoiceRegions(then completion: @escaping ([[String: Any]]?, RequestError?) -> ()) {
    self.sword?.getVoiceRegions(from: self.id, then: completion)
  }

  /// Gets guild's webhooks
  public func getWebhooks(then completion: @escaping ([[String: Any]]?, RequestError?) -> ()) {
    self.sword?.getGuildWebhooks(from: self.id, then: completion)
  }

  /**
   Modifies an integration from this guild

   #### Option Params ####

   - **expire_behavior**: The behavior when an integration subscription lapses (see the [integration](https://discordapp.com/developers/docs/resources/guild#integration-object) object documentation)
   - **expire_grace_period**: Period (in seconds) where the integration will ignore lapsed subscriptions
   - **enable_emoticons**: Whether emoticons should be synced for this integration (twitch only currently), true or false

   - parameter integrationId: Integration to modify
   - parameter options: Preconfigured options to modify this integration with
  */
  public func modifyIntegration(_ integrationId: String, with options: [String: Any], then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword?.modifyIntegration(integrationId, for: self.id, with: options, then: completion)
  }

  /**
   Modifies a member from this guild

   #### Options Params ####

   - **nick**: The nickname to assign
   - **roles**: Array of role id's that should be assigned to the member
   - **mute**: Whether or not to server mute the member
   - **deaf**: Whether or not to server deafen the member
   - **channel_id**: If the user is connected to a voice channel, assigns them the new voice channel they are to connect.

   - parameter userId: Member to modify
   - parameter options: Preconfigured options to modify member with
  */
  public func modifyMember(_ userId: String, with options: [String: Any], then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword?.modifyMember(userId, in: self.id, with: options, then: completion)
  }

  /**
   Modifies a role from this guild

   #### Options Params ####

   - **name**: The name to assign to the role
   - **permissions**: The bitwise permission integer
   - **color**: RGB int color value to assign to the role
   - **hoist**: Whether or not this role should be hoisted on the member list
   - **mentionable**: Whether or not this role should be mentionable by everyone

   - parameter roleId: Role to modify
   - parameter options: Preconfigured options to modify guild roles with
  */
  public func modifyRole(_ roleId: String, with options: [String: Any], then completion: @escaping (Role?, RequestError?) -> () = {_ in}) {
    self.sword?.modifyRole(roleId, for: self.id, with: options, then: completion)
  }

  /**
   Modifies current guild

   #### Options Params ####

   - **name**: The name to assign to the guild
   - **region**: The region to set this guild to
   - **verification_level**: The guild verification level integer
   - **default_message_notifications**: The guild default message notification settings integer
   - **afk_channel_id**: The channel id to assign afks
   - **afk_timeout**: The amount of time in seconds to afk a user in voice
   - **icon**: The icon in base64 string
   - **owner_id**: The user id to make own of this server
   - **splash**: If a VIP server, the splash image in base64 to assign

   - parameter options: Preconfigured options to modify guild with
  */
  public func modify(with options: [String: Any], then completion: @escaping (Guild?, RequestError?) -> () = {_ in}) {
    self.sword?.modifyGuild(self.id, with: options, then: completion)
  }

  /**
   Modifies channel positions

   #### Options Params ####

   Array of the following:

   - **id**: The channel id to modify
   - **position**: The sorting position of the channel

   - parameter options: Preconfigured options to set channel positions to
  */
  public func modifyChannelPositions(with options: [[String: Any]], then completion: @escaping ([GuildChannel]?, RequestError?) -> () = {_ in}) {
    self.sword?.modifyChannelPositions(for: self.id, with: options, then: completion)
  }

  /**
   Modifies role positions

   #### Options Params ####

   Array of the following:

   - **id**: The role id to edit position
   - **position**: The sorting position of the role

   - parameter options: Preconfigured options to set role positions to
  */
  public func modifyRolePositions(with options: [[String: Any]], then completion: @escaping ([Role]?, RequestError?) -> () = {_ in}) {
    self.sword?.modifyRolePositions(for: self.id, with: options, then: completion)
  }

  /**
   Moves a member to another voice channel (if they are in one)

   - parameter channelId: The Id of the channel to send them to
  */
  public func moveMember(_ userId: String, to channelId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword?.moveMember(userId, in: self.id, to: channelId, then: completion)
  }

  /**
   Prunes members for x amount of days

   - parameter limit: Amount of days for prunned users
  */
  public func pruneMembers(for limit: Int, then completion: @escaping (Int?, RequestError?) -> () = {_ in}) {
    self.sword?.pruneMembers(in: self.id, for: limit, then: completion)
  }

  /**
   Removes member from this guild

   - parameter userId: Member to remove from server
  */
  public func removeMember(_ userId: String, for reason: String? = nil, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword?.removeMember(userId, from: self.id, for: reason, then: completion)
  }

  /**
   Syncs an integration from this guild

   - parameter integrationId: Integration to sync
  */
  public func syncIntegration(_ integrationId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword?.syncIntegration(integrationId, for: self.id, then: completion)
  }

  /**
   Unbans a user from this guild

   - parameter userId: User to unban
  */
  public func unbanMember(_ userId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword?.unbanMember(userId, from: self.id, then: completion)
  }

}

/// UnavailableGuild Type
public struct UnavailableGuild {

  // MARK: Properties

  /// ID of this guild
  public let id: Int

  /// ID of shard this guild is handled by
  public let shard: Int

  // MARK: Initializer

  /**
   Creates an UnavailableGuild structure

   - parameter json: JSON representable as a dictionary
   - parameter shard: Shard ID this guild is handled by
  */
  init(_ json: [String: Any], _ shard: Int) {
    self.id = Int(json["id"] as! String)!
    self.shard = shard
  }

}

/// Emoji Type
public struct Emoji {

  // MARK: Properties

  /// ID of custom emoji
  public let id: String

  /// Whether or not this emoji is managed
  public let managed: Bool

  /// Name of the emoji
  public let name: String

  /// Whether this emoji requires colons to use
  public let requireColons: Bool

  /// Array of roles that can use this emoji
  public var roles = [Role]()

  // MARK: Initializer

  /**
   Creates an Emoji structure

   - parameter json: JSON representable as a dictionary
  */
  init(_ json: [String: Any]) {
    self.id = json["id"] as! String
    self.managed = json["managed"] as! Bool
    self.name = json["name"] as! String
    self.requireColons = json["require_colons"] as! Bool

    if let roles = json["roles"] as? [[String: Any]] {
      for role in roles {
        self.roles.append(Role(role))
      }
    }
  }

}
