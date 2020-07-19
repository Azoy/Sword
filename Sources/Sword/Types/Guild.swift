//
//  Guild.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Guild Type
public class Guild: Updatable, Imageable {

  // MARK: Properties

  /// Parent class
  public internal(set) weak var sword: Sword?

  /// ID of afk voice channel (if there is any)
  public internal(set) var afkChannelId: Snowflake?

  /// AFK timeout in seconds (if there is any)
  public internal(set) var afkTimeout: Int?

  /// The member type for the bot user
  public var botMember: Member? {
    guard let user = self.sword?.user else {
      return nil
    }		

    return self.members[user.id]
  }

  /// Collection of channels mapped by channel ID
  public internal(set) var channels = [Snowflake: GuildChannel]()

  /// Default notification protocol
  public internal(set) var defaultMessageNotifications: Int

  /// ID of embeddable channel
  public internal(set) var embedChannelId: Snowflake?

  /// Array of custom emojis for this guild
  public internal(set) var emojis = [Emoji]()

  /// Array of features this guild has
  public internal(set) var features = [Feature]()

  /// Icon hash for guild
  public internal(set) var icon: String?

  /// ID of guild
  public let id: Snowflake

  /// Whether or not this guild is embeddable
  public internal(set) var isEmbedEnabled: Bool?

  /// Whether or not this guild is considered "large"
  public let isLarge: Bool?

  /// The date at which the bot joined the server
  public let joinedAt: Date?

  /// Amount of members this guild has
  public let memberCount: Int?

  /// Collection of members mapped by user ID
  public internal(set) var members = [Snowflake: Member]()

  /// MFA level of guild
  public internal(set) var mfaLevel: MFALevel

  /// Name of the guild
  public internal(set) var name: String

  /// Owner's user ID
  public internal(set) var ownerId: Snowflake

  /// Region this guild is hosted in
  public internal(set) var region: String

  /// Collection of roles mapped by role ID
  public internal(set) var roles = [Snowflake: Role]()

  /// Shard ID this guild is handled by
  public let shard: Int?

  /// Splash Hash for guild
  public internal(set) var splash: String?

  /// Level of verification for guild
  public internal(set) var verificationLevel: VerificationLevel

  /// Collection of member voice states currently in this guild
  public internal(set) var voiceStates = [Snowflake: VoiceState]()

  // MARK: Initializer

  /**
   Creates a Guild structure

   - parameter sword: Parent class
   - parameter json: JSON representable as a dictionary
   - parameter shard: Shard ID this guild is handled by
  */
  init(_ sword: Sword, _ json: [String: Any], _ shard: Int? = nil) {
    self.sword = sword

    self.id = Snowflake(json["id"])!

    self.afkChannelId = Snowflake(json["afk_channel_id"])
    self.afkTimeout = json["afk_timeout"] as? Int

    if let channels = json["channels"] as? [[String: Any]] {
      for channelData in channels {
        switch channelData["type"] as! Int {
        case 0:
          let channel = GuildText(sword, channelData)
          self.channels[channel.id] = channel
        case 2:
          let channel = GuildVoice(sword, channelData)
          self.channels[channel.id] = channel
        case 4:
          let channel = GuildCategory(sword, channelData)
          self.channels[channel.id] = channel
        default: break
        }
      }
      
      for (channelId, channel) in self.channels where channel.type == .guildCategory {
        for (channelId2, channel2) in self.channels where channel.parentId == channelId {
          let channel = channel as! GuildCategory
          channel.channels[channelId2] = channel2
        }
      }
    }

    self.defaultMessageNotifications =
      json["default_message_notifications"] as! Int
    self.embedChannelId = Snowflake(json["embed_channel_id"])
    self.isEmbedEnabled = json["embed_enabled"] as? Bool

    if let emojis = json["emojis"] as? [[String: Any]] {
      for emoji in emojis {
        self.emojis.append(Emoji(emoji))
      }
    }

    if let features = json["features"] as? [String] {
      for feature in features {
        if let selectedFeature = Feature(rawValue: feature) {
          self.features.append(selectedFeature)
        }
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

    self.mfaLevel = MFALevel(rawValue: json["mfa_level"] as! Int)!
    self.name = json["name"] as! String
    self.ownerId = Snowflake(json["owner_id"])!

    self.region = json["region"] as! String

    let roles = json["roles"] as! [[String: Any]]
    for role in roles {
      let role = Role(role)
      self.roles[role.id] = role
    }

    self.shard = shard
    self.splash = json["splash"] as? String
    self.verificationLevel = VerificationLevel(
      rawValue: json["verification_level"] as! Int
    )!

    if let members = json["members"] as? [[String: Any]] {
      for member in members {
        let member = Member(sword, self, member)
        self.members[member.user.id] = member
      }
    }

    if let presences = json["presences"] as? [[String: Any]] {
      for presence in presences {
        let userId = Snowflake((presence["user"] as! [String: Any])["id"])!
        let presence = Presence(presence)
        self.members[userId]?.presence = presence
      }
    }

    if let voiceStates = json["voice_states"] as? [[String: Any]] {
      for voiceState in voiceStates {
        let voiceStateObjc = VoiceState(voiceState)

        self.voiceStates[Snowflake(voiceState["user_id"])!] = voiceStateObjc
        self.members[Snowflake(voiceState["user_id"])!]?.voiceState = voiceStateObjc
      }
    }
  }

  // MARK: Functions

  func update(_ json: [String : Any]) {
    self.afkChannelId = Snowflake(json["afk_channel_id"])
    self.afkTimeout = json["afk_timeout"] as? Int
    
    self.defaultMessageNotifications =
      json["default_message_notifications"] as! Int
    self.embedChannelId = Snowflake(json["embed_channel_id"])
    self.isEmbedEnabled = json["embed_enabled"] as? Bool
    
    if let emojis = json["emojis"] as? [[String: Any]] {
      for emoji in emojis {
        self.emojis.append(Emoji(emoji))
      }
    }
    
    if let features = json["features"] as? [String] {
      for feature in features {
        if let selectedFeature = Feature(rawValue: feature) {
          self.features.append(selectedFeature)
        }
      }
    }
    
    self.icon = json["icon"] as? String
    
    self.mfaLevel = MFALevel(rawValue: json["mfa_level"] as! Int)!
    self.name = json["name"] as! String
    self.ownerId = Snowflake(json["owner_id"])!
    
    self.region = json["region"] as! String
    
    let roles = json["roles"] as! [[String: Any]]
    for role in roles {
      let role = Role(role)
      self.roles[role.id] = role
    }
    
    self.splash = json["splash"] as? String
    self.verificationLevel = VerificationLevel(
      rawValue: json["verification_level"] as! Int
      )!
  }
  
  /**
   Bans a member from this guild

   #### Option Params ####

   - **delete-message-days**: Number of days to delete messages for (0-7)

   - parameter userId: Member to ban
   - parameter reason: Reason why member was banned from guild (attached to audit log)
   - parameter options: Deletes messages from this user by amount of days
  */
  public func ban(
    _ member: Snowflake,
    for reason: String? = nil,
    with options: [String: Int] = [:],
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.sword?.ban(
      member,
      from: self.id,
      for: reason,
      with: options,
      then: completion
    )
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
  public func createChannel(
    with options: [String: Any],
    then completion: ((GuildChannel?, RequestError?) -> ())? = nil
  ) {
    self.sword?.createChannel(for: self.id, with: options, then: completion)
  }

  /**
   Creates an integration for this guild

   #### Option Params ####

   - **type**: The type of integration to create
   - **id**: The id of the user's integration to link to this guild

   - parameter options: Preconfigured options for this integration
  */
  public func createIntegration(
    with options: [String: String],
    then completion: ((RequestError?) -> ())? = nil
  ) {
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
  public func createRole(
    with options: [String: Any],
    then completion: ((Role?, RequestError?) -> ())? = nil
  ) {
    self.sword?.createRole(for: self.id, with: options, then: completion)
  }

  /**
   Deletes an integration from this guild

   - parameter integrationId: Integration to delete
  */
  public func deleteIntegration(
    _ integrationId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.sword?.deleteIntegration(
      integrationId,
      from: self.id,
      then: completion
    )
  }

  /**
   Deletes a role from this guild

   - parameter roleId: Role to delete
  */
  public func deleteRole(
    _ roleId: Snowflake,
    then completion: ((Role?, RequestError?) -> ())? = nil
  ) {
    self.sword?.deleteRole(roleId, from: self.id, then: completion)
  }

  /// Deletes current guild
  public func delete(then completion: ((Guild?, RequestError?) -> ())? = nil) {
    self.sword?.deleteGuild(self.id, then: completion)
  }
  
  /**
   Get's this guild's audit logs
   
   #### Options Params ####
   
   - **user_id**: String of user to look for logs of
   - **action_type**: Integer of Audit Log Event. Refer to [Audit Log Events](https://discord.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-events)
   - **before**: String of entry id to look before
   - **limit**: Integer of how many entries to return (default 50, minimum 1, maximum 100)
   
   - parameter options: Optional flags to request for when getting audit logs
  */
  public func getAuditLog(
    with options: [String: Any]? = nil,
    then completion: @escaping (AuditLog?, RequestError?) -> ()
  ) {
    self.sword?.getAuditLog(from: self.id, with: options, then: completion)
  }
  
  /// Gets guild's bans
  public func getBans(
    then completion: @escaping ([User]?, RequestError?) -> ()
  ) {
    self.sword?.getBans(from: self.id, then: completion)
  }

  /// Gets the guild embed
  public func getEmbed(
    then completion: @escaping ([String: Any]?, RequestError?) -> ()
  ) {
    self.sword?.getGuildEmbed(from: self.id, then: completion)
  }

  /// Gets guild's integrations
  public func getIntegrations(
    then completion: @escaping ([[String: Any]]?, RequestError?) -> ()
  ) {
    self.sword?.getIntegrations(from: self.id, then: completion)
  }

  /// Gets guild's invites
  public func getInvites(
    then completion: @escaping ([[String: Any]]?, RequestError?) -> ()
  ) {
    self.sword?.getGuildInvites(from: self.id, then: completion)
  }

  /**
   Gets an array of guild members

   #### Option Params ####

   - **limit**: Amount of members to get (1-1000)
   - **after**: Message Id of highest member to get members from

   - parameter options: Dictionary containing optional optiond regarding what members are returned
  */
  public func getMembers(
    with options: [String: Any]? = nil,
    then completion: @escaping ([Member]?, RequestError?) -> ()
  ) {
    self.sword?.getMembers(from: self.id, with: options, then: completion)
  }

  /**
   Gets number of users who would be pruned by x amount of days

   - parameter limit: Number of days to get prune count for
  */
  public func getPruneCount(
    for limit: Int,
    then completion: @escaping (Int?, RequestError?) -> ()
  ) {
    self.sword?.getPruneCount(from: self.id, for: limit, then: completion)
  }

  /// Gets guild roles
  public func getRoles(
    then completion: @escaping ([Role]?, RequestError?) -> ()
  ) {
    self.sword?.getRoles(from: self.id, then: completion)
  }

  /// Gets an array of voice regions from guild
  public func getVoiceRegions(
    then completion: @escaping ([[String: Any]]?, RequestError?) -> ()
  ) {
    self.sword?.getVoiceRegions(from: self.id, then: completion)
  }

  /// Gets guild's webhooks
  public func getWebhooks(
    then completion: @escaping ([Webhook]?, RequestError?) -> ()
  ) {
    self.sword?.getGuildWebhooks(from: self.id, then: completion)
  }

  /**
   Gets the link of the guild's icon
   
   - parameter format: File extension of the avatar (default png)
  */
  public func imageUrl(format: FileExtension = .png) -> URL? {
    guard let icon = self.icon else {
      return nil
    }
    // as of 7/18/20, the CDN domain is still cdn.discordapp.com
    return URL(string: "https://cdn.discordapp.com/icons/\(self.id)/\(icon).\(format)")
  }
  
  /**
   Kicks member from this guild

   - parameter userId: Member to kick from server
   - parameter reason: Reason why member was kicked from server
  */
  public func kick(
    _ userId: Snowflake,
    for reason: String? = nil,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.sword?.kick(userId, from: self.id, for: reason, then: completion)
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
  public func modify(
    with options: [String: Any],
    then completion: ((Guild?, RequestError?) -> ())? = nil
  ) {
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
  public func modifyChannelPositions(
    with options: [[String: Any]],
    then completion: (([GuildChannel]?, RequestError?) -> ())? = nil
  ) {
    self.sword?.modifyChannelPositions(
      for: self.id,
      with: options,
      then: completion
    )
  }

  /**
   Modifes this guild's Embed

   #### Options Params ####

   - **enabled**: Whether or not embed should be enabled
   - **channel_id**: Snowflake of embed channel

   - parameter options: Dictionary of options to give embed
  */
  public func modifyEmbed(
    with options: [String: Any],
    then completion: (([String: Any]?, RequestError?) -> ())? = nil
  ) {
    self.sword?.modifyEmbed(for: self.id, with: options, then: completion)
  }

  /**
   Modifies an integration from this guild

   #### Option Params ####

   - **expire_behavior**: The behavior when an integration subscription lapses (see the [integration](https://discord.com/developers/docs/resources/guild#integration-object) object documentation)
   - **expire_grace_period**: Period (in seconds) where the integration will ignore lapsed subscriptions
   - **enable_emoticons**: Whether emoticons should be synced for this integration (twitch only currently), true or false

   - parameter integrationId: Integration to modify
   - parameter options: Preconfigured options to modify this integration with
  */
  public func modifyIntegration(
    _ integrationId: Snowflake,
    with options: [String: Any],
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.sword?.modifyIntegration(
      integrationId,
      for: self.id,
      with: options,
      then: completion
    )
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
  public func modifyMember(
    _ userId: Snowflake,
    with options: [String: Any],
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.sword?.modifyMember(
      userId,
      in: self.id,
      with: options,
      then: completion
    )
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
  public func modifyRole(
    _ roleId: Snowflake,
    with options: [String: Any],
    then completion: ((Role?, RequestError?) -> ())? = nil
  ) {
    self.sword?.modifyRole(
      roleId,
      for: self.id,
      with: options,
      then: completion
    )
  }

  /**
   Modifies role positions

   #### Options Params ####

   Array of the following:

   - **id**: The role id to edit position
   - **position**: The sorting position of the role

   - parameter options: Preconfigured options to set role positions to
  */
  public func modifyRolePositions(
    with options: [[String: Any]],
    then completion: (([Role]?, RequestError?) -> ())? = nil
  ) {
    self.sword?.modifyRolePositions(
      for: self.id,
      with: options,
      then: completion
    )
  }

  /**
   Moves a member to another voice channel (if they are in one)

   - parameter channelId: The Id of the channel to send them to
  */
  public func moveMember(
    _ userId: Snowflake,
    to channelId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.sword?.moveMember(userId, in: self.id, to: channelId, then: completion)
  }

  /**
   Prunes members for x amount of days

   - parameter limit: Amount of days for prunned users
  */
  public func pruneMembers(
    for limit: Int,
    then completion: ((Int?, RequestError?) -> ())? = nil
  ) {
    self.sword?.pruneMembers(in: self.id, for: limit, then: completion)
  }

  /**
   Syncs an integration from this guild

   - parameter integrationId: Integration to sync
  */
  public func syncIntegration(
    _ integrationId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.sword?.syncIntegration(integrationId, for: self.id, then: completion)
  }

  /**
   Unbans a user from this guild

   - parameter userId: User to unban
  */
  public func unbanMember(
    _ userId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.sword?.unbanMember(userId, from: self.id, then: completion)
  }

}

extension Guild {
  
  /// Guild features
  public enum Feature: String {
    
    /// Custom image for invites
    case inviteSplash = "INVITE_SPLASH"
    
    /// Custom url to join the guild with
    case vanityUrl = "VANITY_URL"
    
    /// VIP voice channels for crisp audio
    case vipRegions = "VIP_REGIONS"
    
    /// Is a verified discord
    case verified = "VERIFIED"
  }
  
  /// Level of verification for admisitrative actions for guild
  public enum MFALevel: Int {
    
    /// Admisitration actions don't require 2fa
    case none
    
    /// Admisitration actions require 2fa
    case elevated
  }
  
  /// Level of verification for guild
  public enum VerificationLevel: Int {
    
    /// Unrestricted
    case none
    
    /// Must have a verified email on their Discord account
    case low
    
    /// Low + must be a Discord user for longer than 5 minutes
    case medium
    
    /// Medium + must be a member of guild for 10 minutes
    case high
    
    /// High + must have a verified phone number on their Discord account
    case veryHigh
  }
  
}

/// UnavailableGuild Type
public struct UnavailableGuild {
  
  // MARK: Properties
  
  /// ID of this guild
  public let id: Snowflake
  
  /// ID of shard this guild is handled by
  public let shard: Int
  
  // MARK: Initializer
  
  /**
   Creates an UnavailableGuild structure
   
   - parameter json: JSON representable as a dictionary
   - parameter shard: Shard ID this guild is handled by
   */
  init(_ json: [String: Any], _ shard: Int) {
    self.id = Snowflake(json["id"])!
    self.shard = shard
  }
  
}

/// Similar to a Guild type, but provides bare minimal info
public struct UserGuild {
  
  // MARK: Properties
  
  /// The icon Base64 string
  public let icon: String?
  
  /// The guild ID
  public let id: Snowflake
  
  /// Whether or not the current user owns this guild
  public let isOwner: Bool
  
  /// The name of the guild
  public let name: String
  
  /// The permission number that the current user has in this guild
  public let permissions: Int
  
  // MARK: Initializer
  
  /// Creates a UserGuild structure
  init(_ json: [String: Any]) {
    self.icon = json["icon"] as? String
    self.id = Snowflake(json["id"])!
    self.isOwner = json["owner"] as! Bool
    self.name = json["name"] as! String
    self.permissions = json["permissions"] as! Int
  }
  
}
