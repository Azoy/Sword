//
//  Sword.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation
import Dispatch

/// Main Class for Sword
open class Sword: Eventable {

  // MARK: Properties

  /// Collection of DMChannels mapped by user id
  public internal(set) var dms = [Snowflake: DM]() {
    didSet {
      guard dms.count > 10 else {
        return
      }
      
      dms.removeValue(forKey: dms.first!.key)
    }
  }
  
  /// Whether or not the global queue is locked
  var isGloballyLocked = false

  /// The queue that handles requests made after being globally limited
  lazy var globalQueue: DispatchQueue = DispatchQueue(
    label: "me.azoy.sword.rest.global"
  )

  /// Used to store requests when being globally rate limited
  var globalRequestQueue = [() -> ()]()

  /// Collection of group channels the bot is connected to
  public internal(set) var groups = [Snowflake: GroupDM]()

  /// Colectionl of guilds the bot is currently connected to
  public internal(set) var guilds = [Snowflake: Guild]()

  /// Event listeners
  public var listeners = [Event: [(Any) -> ()]]()

  /// Optional options to apply to bot
  var options: SwordOptions

  /// Initial presence of bot
  var presence: [String: Any]? = nil
  
  /// Collection of Collections of buckets mapped by route
  var rateLimits = [String: Bucket]()

  /// Timestamp of ready event
  public internal(set) var readyTimestamp: Date?

  /// Global URLSession (trust me i saw it on a wwdc talk, this is legit lmfao)
  let session = URLSession(
    configuration: .default,
    delegate: nil,
    delegateQueue: OperationQueue()
  )

  /// Amount of shards to initialize
  public internal(set) var shardCount = 1

  /// Shard Handler
  lazy var shardManager = ShardManager()

  /// How many shards are ready
  var shardsReady = 0

  /// The bot token
  let token: String

  /// Array of unavailable guilds the bot is currently connected to
  public internal(set) var unavailableGuilds = [Snowflake: UnavailableGuild]()

  /// Int in seconds of how long the bot has been online
  public var uptime: Int? {
    if let timestamp = self.readyTimestamp {
      return Int(Date().timeIntervalSince(timestamp))
    }else {
      return nil
    }
  }

  /// The user account for the bot
  public internal(set) var user: User?

  #if os(macOS) || os(Linux)

  /// Object of voice connections the bot is currently connected to. Mapped by guildId
  public var voiceConnections: [Snowflake: VoiceConnection] {
    return self.voiceManager.connections
  }

  /// Voice handler
  lazy var voiceManager = VoiceManager()

  #endif

  // MARK: Initializer

  /**
   Initializes the Sword class

   - parameter token: The bot token
   - parameter options: Options to give bot (sharding, offline members, etc)
  */
  public init(token: String, with options: SwordOptions = SwordOptions()) {
    self.options = options
    self.token = token
  }
  
  // MARK: Functions

  /**
   Adds a reaction (unicode or custom emoji) to a message

   - parameter reaction: Unicode or custom emoji reaction
   - parameter messageId: Message to add reaction to
   - parameter channelId: Channel to add reaction to message in
  */
  public func addReaction(
    _ reaction: String,
    to messageId: Snowflake,
    in channelId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(
      .createReaction(
        channelId,
        messageId,
        reaction.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)
    ) { data, error in
      completion?(error)
    }
  }

  /**
   Bans a member from a guild

   #### Option Params ####

   - **delete-message-days**: Number of days to delete messages for (0-7)

   - parameter userId: Member to ban
   - parameter guildId: Guild to ban member in
   - parameter reason: Reason why member was banned from guild (attached to audit log)
   - parameter options: Deletes messages from this user by amount of days
  */
  public func ban(
    _ userId: Snowflake,
    from guildId: Snowflake,
    for reason: String? = nil,
    with options: [String: Any] = [:],
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(
      .createGuildBan(guildId, userId),
      body: options,
      reason: reason
    ) { data, error in
      completion?(error)
    }
  }
  
  /// Starts the bot
  public func connect() {
    self.shardManager.sword = self
    
    if self.options.willShard {
      self.getGateway() { [unowned self] data, error in
        guard let data = data else {
          guard error!.statusCode == 401 else {
            sleep(3)
            self.connect()
            return
          }
          
          print("[Sword] Bot token invalid.")
          return
        }
        
        self.shardManager.gatewayUrl = "\(data["url"]!)/?encoding=json&v=6"
        self.shardCount = data["shards"] as! Int
        
        guard self.options.isDistributed else {
          self.shardManager.create(self.shardCount)
          return
        }
        
        let arguments = CommandLine.arguments
        
        guard arguments.count > 1 else {
          print("[Sword] Insufficient argument count.")
          return
        }
        
        guard arguments.contains("--shard") else {
          print("[Sword] Must specify shard with '--shard'")
          return
        }
        
        guard arguments.index(of: "--shard")! != arguments.count - 1 else {
          print("[Sword] '--shard' must not be the last argument. Correct syntax is '--shard {id here}'")
          return
        }
        
        guard let shardId = Int(arguments[arguments.index(of: "--shard")! + 1]) else {
          print("[Sword] Shard ID could not be recognized.")
          return
        }
        
        self.shardManager.spawn(shardId)
      }
    }else {
      self.shardCount = 1
      
      self.shardManager.create(self.shardCount)
    }
    
    #if os(macOS)
    CFRunLoopRun()
    #endif
  }
  
  /**
   Creates a channel in a guild

   #### Option Params ####

   - **name**: The name to give this channel
   - **type**: The type of channel to create
   - **bitrate**: If a voice channel, sets the bitrate for the voice channel
   - **user_limit**: If a voice channel, sets the maximum amount of users to be allowed at a time
   - **permission_overwrites**: Array of overwrite objects to give this channel

   - parameter guildId: Guild to create channel for
   - parameter options: Preconfigured options to give the channel on create
  */
  public func createChannel(
    for guildId: Snowflake,
    with options: [String: Any],
    then completion: ((GuildChannel?, RequestError?) -> ())? = nil
  ) {
    self.request(
      .createGuildChannel(guildId),
      body: options
    ) { [unowned self] data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        let data = data as! [String: Any]
        
        switch data["type"] as! Int {
        case 0:
          completion?(GuildText(self, data), error)
          
        case 2:
          completion?(GuildVoice(self, data), error)
          
        case 4:
          completion?(GuildCategory(self, data), error)
          
        default:
          completion?(nil, error)
        }
      }
    }
  }

  /**
   Creates a guild

   - parameter options: Refer to [discord docs](https://discordapp.com/developers/docs/resources/guild#create-guild) for guild options
  */
  public func createGuild(
    with options: [String: Any],
    then completion: ((Guild?, RequestError?) -> ())? = nil
  ) {
    self.request(.createGuild, body: options) { [unowned self] data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        completion?(Guild(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Creates an integration for a guild

   #### Option Params ####

   - **type**: The type of integration to create
   - **id**: The id of the user's integration to link to this guild

   - parameter guildId: Guild to create integration for
   - parameter options: Preconfigured options for this integration
  */
  public func createIntegration(
    for guildId: Snowflake,
    with options: [String: String],
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(
      .createGuildIntegration(guildId),
      body: options
    ) { data, error in
      completion?(error)
    }
  }

  /**
   Creates an invite for channel

   #### Options Params ####

   - **max_age**: Duration in seconds before the invite expires, or 0 for never. Default 86400 (24 hours)
   - **max_uses**: Max number of people who can use this invite, or 0 for unlimited. Default 0
   - **temporary**: Whether or not this invite gives you temporary access to the guild. Default false
   - **unique**: Whether or not this invite has a unique invite code. Default false

   - parameter channelId: Channel to create invite for
   - parameter options: Options to give invite
  */
  public func createInvite(
    for channelId: Snowflake,
    with options: [String: Any] = [:],
    then completion: (([String: Any]?, RequestError?) -> ())? = nil
  ) {
    self.request(
      .createChannelInvite(channelId),
      body: options
    ) { data, error in
      completion?(data as? [String: Any], error)
    }
  }

  /**
   Creates a guild role

   #### Option Params ####

   - **name**: The name of the role
   - **permissions**: The bitwise number to set role with
   - **color**: Integer value of RGB color
   - **hoist**: Whether or not this role is hoisted on the member list
   - **mentionable**: Whether or not this role is mentionable in chat

   - parameter guildId: Guild to create role for
   - parameter options: Preset options to configure role with
  */
  public func createRole(
    for guildId: Snowflake,
    with options: [String: Any],
    then completion: ((Role?, RequestError?) -> ())? = nil
  ) {
    self.request(.createGuildRole(guildId), body: options) { data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        completion?(Role(data as! [String: Any]), nil)
      }
    }
  }

  /**
   Creates a webhook for a channel

   #### Options Params ####

   - **name**: The name of the webhook
   - **avatar**: The avatar string to assign this webhook in base64

   - parameter channelId: Guild channel to create webhook for
   - parameter options: Preconfigured options to create this webhook with
  */
  public func createWebhook(
    for channelId: Snowflake,
    with options: [String: String] = [:],
    then completion: ((Webhook?, RequestError?) -> ())? = nil
  ) {
    self.request(
      .createWebhook(channelId),
      body: options
    ) { [unowned self] data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        completion?(Webhook(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Deletes a channel

   - parameter channelId: Channel to delete
  */
  public func deleteChannel(
    _ channelId: Snowflake,
    then completion: ((Channel?, RequestError?) -> ())? = nil
  ) {
    self.request(.deleteChannel(channelId)) { [unowned self] data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        let channelData = data as! [String: Any]
        
        switch channelData["type"] as! Int {
        case 0:
          completion?(GuildText(self, channelData), error)
          
        case 1:
          completion?(DM(self, channelData), error)
          
        case 2:
          completion?(GuildVoice(self, channelData), error)
          
        case 3:
          completion?(GroupDM(self, channelData), error)
          
        case 4:
          completion?(GuildCategory(self, channelData), error)
          
        default: break
        }
      }
    }
  }

  /**
   Deletes a guild

   - parameter guildId: Guild to delete
  */
  public func deleteGuild(
    _ guildId: Snowflake,
    then completion: ((Guild?, RequestError?) -> ())? = nil
  ) {
    self.request(.deleteGuild(guildId)) { [unowned self] data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        completion?(Guild(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Deletes an integration from a guild

   - parameter integrationId: Integration to delete
   - parameter guildId: Guild to delete integration from
  */
  public func deleteIntegration(
    _ integrationId: Snowflake,
    from guildId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(
      .deleteGuildIntegration(guildId, integrationId)
    ) { data, error in
      completion?(error)
    }
  }

  /**
   Deletes an invite

   - parameter inviteId: Invite to delete
  */
  public func deleteInvite(
    _ inviteId: String,
    then completion: ((Invite?, RequestError?) -> ())? = nil
  ) {
    self.request(
      .deleteInvite(invite: inviteId)
    ) { [unowned self] data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        completion?(Invite(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Deletes a message from a channel

   - parameter messageId: Message to delete
  */
  public func deleteMessage(
    _ messageId: Snowflake,
    from channelId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(.deleteMessage(channelId, messageId)) { data, error in
      completion?(error)
    }
  }

  /**
   Bulk deletes messages

   - parameter messages: Array of message ids to delete
  */
  public func deleteMessages(
    _ messages: [Snowflake],
    from channelId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    let oldestMessage = Snowflake.fakeSnowflake(
      date: Date(timeIntervalSinceNow: -14 * 24 * 60 * 60)
    ) ?? 0
    
    for message in messages {
      if message < oldestMessage {
        completion?(
          RequestError(
            "One of the messages you wanted to delete was older than allowed."
          )
        )
      }
    }

    self.request(
      .bulkDeleteMessages(channelId),
      body: ["messages": messages.map { $0.description }]
    ) { data, error in
      completion?(error)
    }
  }

  /**
   Deletes an overwrite permission for a channel

   - parameter channelId: Channel to delete permissions from
   - parameter overwriteId: Overwrite ID to use for permissons
  */
  public func deletePermission(
    from channelId: Snowflake,
    with overwriteId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(
      .deleteChannelPermission(channelId, overwriteId)
    ) { data, error in
      completion?(error)
    }
  }

  /**
   Deletes a reaction from a message by user

   - parameter reaction: Unicode or custom emoji to delete
   - parameter messageId: Message to delete reaction from
   - parameter userId: If nil, deletes bot's reaction from, else delete a reaction from user
   - parameter channelId: Channel to delete reaction from
  */
  public func deleteReaction(
    _ reaction: String,
    from messageId: Snowflake,
    by userId: Snowflake? = nil,
    in channelId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    let reaction = reaction.addingPercentEncoding(
      withAllowedCharacters: .urlPathAllowed
    )!
    let url: Endpoint
    if let userId = userId {
      url = .deleteUserReaction(channelId, messageId, reaction, userId)
    }else {
      url = .deleteOwnReaction(channelId, messageId, reaction)
    }

    self.request(url) { data, error in
      completion?(error)
    }
  }

  /**
   Deletes all reactions from a message

   - parameter messageId: Message to delete all reactions from
   - parameter channelId: Channel to remove reactions in
  */
  public func deleteReactions(
    from messageId: Snowflake,
    in channelId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(.deleteAllReactions(channelId, messageId)) { data, error in
      completion?(error)
    }
  }

  /**
   Deletes a role from this guild

   - parameter roleId: Role to delete
   - parameter guildId: Guild to delete role from
  */
  public func deleteRole(
    _ roleId: Snowflake,
    from guildId: Snowflake,
    then completion: ((Role?, RequestError?) -> ())? = nil
  ) {
    self.request(.deleteGuildRole(guildId, roleId)) { data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        completion?(Role(data as! [String: Any]), nil)
      }
    }
  }

  /**
   Deletes a webhook

   - parameter webhookId: Webhook to delete
  */
  public func deleteWebhook(
    _ webhookId: Snowflake,
    token: String? = nil,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(.deleteWebhook(webhookId, token)) { data, error in
      completion?(error)
    }
  }
  
  /// Disconnects the bot from the gateway
  public func disconnect() {
    self.shardManager.disconnect()
  }
  
  /**
   Edits a message's content

   - parameter messageId: Message to edit
   - parameter options: Dictionary c
   - parameter channelId: Channel to edit message in
  */
  public func editMessage(
    _ messageId: Snowflake,
    with options: [String: Any],
    in channelId: Snowflake,
    then completion: ((Message?, RequestError?) -> ())? = nil
  ) {
    self.request(
      .editMessage(channelId, messageId),
      body: options
    ) { [unowned self] data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        completion?(Message(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
    Edits a channel's overwrite permission

   #### Option Params ####

   - **allow**: The bitwise allowed permissions
   - **deny**: The bitwise denied permissions
   - **type**: 'member' for a user, or 'role' for a role

   - parameter permissions: ["allow": perm#, "deny": perm#, "type": "role" || "member"]
   - parameter channelId: Channel to edit permissions for
   - parameter overwriteId: Overwrite ID to use for permissions
  */
  public func editPermissions(
    _ permissions: [String: Any],
    for channelId: Snowflake,
    with overwriteId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(
      .editChannelPermissions(channelId, overwriteId),
      body: permissions
    ) { data, error in
      completion?(error)
    }
  }
  
  /**
   Edits bot status
   
   - parameter status: Status to set bot to. Either "online" (default), "idle", "dnd", "invisible"
   - parameter game: A string containing the song the bot is listening to
   */
  public func editStatus(to status: String, listening song: String) {
    let game: [String: Any] = [
      "name": song,
      "type": 0
    ]
    
    self.editStatus(to: status, playing: game)
  }
  
  /**
   Edits bot status
   
   - parameter status: Status to set bot to. Either "online" (default), "idle", "dnd", "invisible"
   - parameter game: A string containing the game the bot is playing
  */
  public func editStatus(to status: String, playing game: String) {
    let game: [String: Any] = [
      "name": game,
      "type": 0
    ]
    
    self.editStatus(to: status, playing: game)
  }
  
  /**
   Edits bot status
   
   #### Game Options ####
   - **name**: Name of the game playing/streaming
   - **type**: 0 for a normal playing game, or 1 for streaming
   - **url**: Required if streaming, the url discord displays for streams
   
   - parameter status: Status to set bot to. Either "online" (default), "idle", "dnd", "invisible"
   - parameter game: Dictonary with information on the game
  */
  public func editStatus(to status: String, playing game: [String: Any]? = nil) {
    var data: [String: Any] = [
      "afk": status == "idle",
      "since": status == "idle" ? Date().milliseconds : 0,
      "status": status
    ]
    
    if let game = game {
      data["game"] = game
    }
    
    guard self.shardManager.shards.count > 0 else {
      self.presence = data
      return
    }
    
    let payload = Payload(op: .statusUpdate, data: data).encode()
    
    for shard in self.shardManager.shards {
      shard.send(payload, presence: true)
    }
  }
  
  /**
   Edits bot status
   
   - parameter status: Status to set bot to. Either "online" (default), "idle", "dnd", "invisible"
   - parameter video: A string containing the video the bot is watching
   */
  public func editStatus(to status: String, watching video: String) {
    let game: [String: Any] = [
      "name": video,
      "type": 0
    ]
    
    self.editStatus(to: status, playing: game)
  }
  
  /**
   Executs a slack style webhook

   #### Content Params ####

   Refer to the [slack documentation](https://api.slack.com/incoming-webhooks) for their webhook structure

   - parameter webhookId: Webhook to execute
   - parameter webhookToken: Token for auth to execute
   - parameter content: The slack webhook content to send
  */
  public func executeSlackWebhook(
    _ webhookId: Snowflake,
    token webhookToken: String,
    with content: [String: Any],
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(
      .executeSlackWebhook(webhookId, webhookToken),
      body: content
    ) { data, error in
      completion?(error)
    }
  }

  /**
   Executes a webhook

   #### Content Params ####

   - **content**: Message to send
   - **username**: The username the webhook will send with the message
   - **avatar_url**: The url of the user the webhook will send
   - **tts**: Whether or not this message is tts
   - **file**: The url of the image to send
   - **embeds**: Array of embed objects to send. Refer to [Embed structure](https://discordapp.com/developers/docs/resources/channel#embed-object)

   - parameter webhookId: Webhook to execute
   - parameter webhookToken: Token for auth to execute
   - parameter content: String or dictionary containing message content
  */
  public func executeWebhook(
    _ webhookId: Snowflake,
    token webhookToken: String,
    with content: Any,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    guard var message = content as? [String: Any] else {
      self.request(
        .executeWebhook(webhookId, webhookToken),
        body: ["content": content]
      ) { data, error in
        completion?(error)
      }
      return
    }
    
    var file: String? = nil

    if let messageFile = message["file"] {
      file = messageFile as? String
      message.removeValue(forKey: "file")
    }

    self.request(
      .executeWebhook(webhookId, webhookToken),
      body: message,
      file: file
    ) { data, error in
      completion?(error)
    }

  }
  
  /**
   Get's a guild's audit logs
   
   #### Options Params ####
   
   - **user_id**: String of user to look for logs of
   - **action_type**: Integer of Audit Log Event. Refer to [Audit Log Events](https://discordapp.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-events)
   - **before**: String of entry id to look before
   - **limit**: Integer of how many entries to return (default 50, minimum 1, maximum 100)
   
   - parameter guildId: Guild to get audit logs from
   - parameter options: Optional flags to request for when getting audit logs
  */
  public func getAuditLog(
    from guildId: Snowflake,
    with options: [String: Any]? = nil,
    then completion: @escaping (AuditLog?, RequestError?) -> ()
  ) {
    self.request(.getGuildAuditLogs(guildId), params: options) { data, error in
      if let error = error {
        completion(nil, error)
      }else {
        completion(AuditLog(self, data as! [String: [Any]]), error)
      }
    }
  }
  
  /**
   Gets a guild's bans

   - parameter guildId: Guild to get bans from
  */
  public func getBans(
    from guildId: Snowflake,
    then completion: @escaping ([User]?, RequestError?) -> ()
  ) {
    self.request(.getGuildBans(guildId)) { [unowned self] data, error in
      if let error = error {
        completion(nil, error)
      }else {
        var returnUsers: [User] = []
        let users = data as! [[String: Any]]
        for user in users {
          returnUsers.append(User(self, user))
        }

        completion(returnUsers, nil)
      }
    }
  }
  
  /**
   Get's a basic Channel from a ChannelID (NOTE: This tries to get a channel from cache)
   
   - parameter channelId: The ChannelID used to get the Channel
  */
  public func getChannel(for channelId: Snowflake) -> Channel? {
    if let guild = self.getGuild(for: channelId) {
      return guild.channels[channelId]
    }
    
    if let dm = self.getDM(for: channelId) {
      return dm
    }
    
    return self.groups[channelId]
  }
  
  /**
   Either get a cached channel or restfully get a channel

   - parameter channelId: Channel to get
  */
  public func getChannel(
    _ channelId: Snowflake,
    rest: Bool = false,
    then completion: @escaping (Channel?, RequestError?) -> ()
  ) {
    guard rest else {
      completion(self.getChannel(for: channelId), nil)
      return
    }

    self.request(.getChannel(channelId)) { [unowned self] data, error in
      if let error = error {
        completion(nil, error)
      }else {
        let channelData = data as! [String: Any]
        
        switch channelData["type"] as! Int {
        case 0:
          completion(GuildText(self, channelData), error)
          
        case 1:
          completion(DM(self, channelData), error)
          
        case 2:
          completion(GuildVoice(self, channelData), error)
          
        case 3:
          completion(GroupDM(self, channelData), error)
          
        case 4:
          completion(GuildCategory(self, channelData), error)
          
        default: break
        }
      }
    }
  }

  /**
   Gets a channel's invites

   - parameter channelId: Channel to get invites from
  */
  public func getChannelInvites(
    from channelId: Snowflake,
    then completion: @escaping ([[String: Any]]?, RequestError?) -> ()
  ) {
    self.request(.getChannelInvites(channelId)) { data, error in
      completion(data as? [[String: Any]], error)
    }
  }

  /**
   Either get cached channels from guild

   - parameter guildId: Guild to get channels from
  */
  public func getChannels(
    from guildId: Snowflake,
    rest: Bool = false,
    then completion: @escaping ([GuildChannel]?, RequestError?) -> ()
  ) {
    guard rest else {
      guard let guild = self.guilds[guildId] else {
        completion(nil, nil)
        return
      }

      completion(Array(guild.channels.values), nil)
      return
    }

    self.request(.getGuildChannels(guildId)) { [unowned self] data, error in
      if let error = error {
        completion(nil, error)
      }else {
        var returnChannels = [GuildChannel]()
        let channels = data as! [[String: Any]]
        for channel in channels {
          switch channel["type"] as! Int {
          case 0:
            returnChannels.append(GuildText(self, channel))
          case 2:
            returnChannels.append(GuildVoice(self, channel))
          case 4:
            returnChannels.append(GuildCategory(self, channel))
          default: break
          }
        }
        
        completion(returnChannels, nil)
      }
    }
  }

  /// Gets the current user's connections
  public func getConnections(
    then completion: @escaping ([[String: Any]]?, RequestError?) -> ()
  ) {
    self.request(.getUserConnections) { data, error in
      completion(data as? [[String: Any]], error)
    }
  }

  /**
   Function to get dm from channelId (NOTE: This tries to get a DM from cache)

   - parameter channelId: Channel to get dm from
  */
  public func getDM(for channelId: Snowflake) -> DM? {
    let dms = self.dms.filter {
      $0.1.id == channelId
    }

    if dms.isEmpty { return nil }
    
    return dms.first?.value
  }

  /**
   Gets a DM for a user

   - parameter userId: User to get DM for
  */
  public func getDM(
    for userId: Snowflake,
    then completion: @escaping (DM?, RequestError?) -> ()
  ) {
    guard self.dms[userId] == nil else {
      completion(self.dms[userId], nil)
      return
    }
    
    self.request(
      .createDM,
      body: ["recipient_id": userId.description]
    ) { [unowned self] data, error in
      if let error = error {
        completion(nil, error)
      }else {
        let dm = DM(self, data as! [String: Any])
        self.dms[userId] = dm
        completion(dm, nil)
      }
    }
  }
  
  /// Gets the gateway URL to connect to
  public func getGateway(
    then completion: @escaping ([String: Any]?, RequestError?) -> ()
  ) {
    self.request(.gateway) { data, error in
      completion(data as? [String: Any], error)
    }
  }
  
  /**
   Function to get guild from channelId

   - parameter channelId: Channel to get guild from
  */
  public func getGuild(for channelId: Snowflake) -> Guild? {
    let guilds = self.guilds.filter {
      $0.1.channels[channelId] != nil
    }

    if guilds.isEmpty { return nil }
    
    return guilds.first?.value
  }

  /**
   Either get a cached guild or restfully get a guild

   - parameter guildId: Guild to get
   - parameter rest: Whether or not to get this guild restfully or not
  */
  public func getGuild(
    _ guildId: Snowflake,
    rest: Bool = false,
    then completion: @escaping (Guild?, RequestError?) -> ()
  ) {
    guard rest else {
      completion(self.guilds[guildId], nil)
      return
    }

    self.request(.getGuild(guildId)) { [unowned self] data, error in
      if let error = error {
        completion(nil, error)
      }else {
        completion(Guild(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Gets a guild's embed

   - parameter guildId: Guild to get embed from
  */
  public func getGuildEmbed(
    from guildId: Snowflake,
    then completion: @escaping ([String: Any]?, RequestError?) -> ()
  ) {
    self.request(.getGuildEmbed(guildId)) { data, error in
      completion(data as? [String: Any], error)
    }
  }

  /**
   Gets a guild's invites

   - parameter guildId: Guild to get invites from
  */
  public func getGuildInvites(
    from guildId: Snowflake,
    then completion: @escaping ([[String: Any]]?, RequestError?) -> ()
  ) {
    self.request(.getGuildInvites(guildId)) { data, error in
      completion(data as? [[String: Any]], error)
    }
  }

  /**
   Gets a guild's webhooks

   - parameter guildId: Guild to get webhooks from
  */
  public func getGuildWebhooks(
    from guildId: Snowflake,
    then completion: @escaping ([Webhook]?, RequestError?) -> ()
  ) {
    self.request(.getGuildWebhooks(guildId)) { [unowned self] data, error in
      if let error = error {
        completion(nil, error)
      }else {
        var returnWebhooks = [Webhook]()
        let webhooks = data as! [[String: Any]]
        for webhook in webhooks {
          returnWebhooks.append(Webhook(self, webhook))
        }
        
        completion(returnWebhooks, error)
      }
    }
  }

  /**
   Gets a guild's integrations

   - parameter guildId: Guild to get integrations from
  */
  public func getIntegrations(
    from guildId: Snowflake,
    then completion: @escaping ([[String: Any]]?, RequestError?) -> ()
  ) {
    self.request(.getGuildIntegrations(guildId)) { data, error in
      completion(data as? [[String: Any]], error)
    }
  }

  /**
   Gets an invite

   - parameter inviteId: Invite to get
  */
  public func getInvite(
    _ inviteId: String,
    then completion: @escaping ([String: Any]?, RequestError?) -> ()
  ) {
    self.request(.getInvite(invite: inviteId)) { data, error in
      completion(data as? [String: Any], error)
    }
  }

  /**
   Gets a member from guild

   - parameter userId: Member to get
   - parameter guildId: Guild to get member from
  */
  public func getMember(
    _ userId: Snowflake,
    from guildId: Snowflake,
    then completion: @escaping (Member?, RequestError?) -> ()
    ) {
    self.request(
      .getGuildMember(guildId, userId)
    ) { [unowned self] data, error in
      if let error = error {
        completion(nil, error)
      }else {
        let member = Member(self, self.guilds[guildId]!, data as! [String: Any])
        completion(member, nil)
      }
    }
  }

  /**
   Gets an array of guild members in a guild

   #### Option Params ####

   - **limit**: Amount of members to get (1-1000)
   - **after**: Message Id of highest member to get members from

   - parameter guildId: Guild to get members from
   - parameter options: Dictionary containing optional optiond regarding what members are returned
  */
  public func getMembers(
    from guildId: Snowflake,
    with options: [String: Any]? = nil,
    then completion: @escaping ([Member]?, RequestError?) -> ()
  ) {
    self.request(
      .listGuildMembers(guildId),
      params: options
    ) { [unowned self] data, error in
      if let error = error {
        completion(nil, error)
      }else {
        var returnMembers = [Member]()
        let members = data as! [[String: Any]]
        for member in members {
          returnMembers.append(Member(self, self.guilds[guildId]!, member))
        }

        completion(returnMembers, nil)
      }
    }
  }

  /**
   Gets a message from channel

   - parameter messageId: Message to get
   - parameter channelId: Channel to get message from
  */
  public func getMessage(
    _ messageId: Snowflake,
    from channelId: Snowflake,
    then completion: @escaping (Message?, RequestError?) -> ()
  ) {
    self.request(
      .getChannelMessage(channelId, messageId)
    ) { [unowned self] data, error in
      if let error = error {
        completion(nil, error)
      }else {
        completion(Message(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Gets an array of messages from channel

   #### Option Params ####

   - **around**: Message Id to get messages around
   - **before**: Message Id to get messages before this one
   - **after**: Message Id to get messages after this one
   - **limit**: Number of how many messages you want to get (1-100)

   - parameter channelId: Channel to get messages from
   - parameter options: Dictionary containing optional options regarding how many messages, or when to get them
  */
  public func getMessages(
    from channelId: Snowflake,
    with options: [String: Any]? = nil,
    then completion: @escaping ([Message]?, RequestError?) -> ()
  ) {
    self.request(
      .getChannelMessages(channelId),
      params: options
    ) { [unowned self] data, error in
      if let error = error {
        completion(nil, error)
      }else {
        var returnMessages = [Message]()
        let messages = data as! [[String: Any]]
        for message in messages {
          returnMessages.append(Message(self, message))
        }
        
        completion(returnMessages, nil)
      }
    }
  }

  /**
   Get pinned messages from a channel

   - parameter channelId: Channel to get pinned messages fromn
  */
  public func getPinnedMessages(
    from channelId: Snowflake,
    then completion: @escaping ([Message]?, RequestError?) -> ()
  ) {
    self.request(.getPinnedMessages(channelId)) { [unowned self] data, error in
      if let error = error {
        completion(nil, error)
      }else {
        var returnMessages = [Message]()
        let messages = data as! [[String: Any]]
        for message in messages {
          returnMessages.append(Message(self, message))
        }

        completion(returnMessages, nil)
      }
    }
  }

  /**
   Gets number of users who would be pruned by x amount of days in a guild

   - parameter guildId: Guild to get prune count for
   - parameter limit: Number of days to get prune count for
  */
  public func getPruneCount(
    from guildId: Snowflake,
    for limit: Int,
    then completion: @escaping (Int?, RequestError?) -> ()
  ) {
    self.request(
      .getGuildPruneCount(guildId),
      params: ["days": limit]
    ) { data, error in
      completion((data as! [String: Int])["pruned"], error)
    }
  }

  /**
   Gets an array of users who used reaction from message

   - parameter reaction: Unicode or custom emoji to get
   - parameter messageId: Message to get reaction users from
   - parameter channelId: Channel to get reaction from
  */
  public func getReaction(
    _ reaction: String,
    from messageId: Snowflake,
    in channelId: Snowflake,
    then completion: @escaping ([User]?, RequestError?) -> ()
  ) {
    self.request(
      .getReactions(
        channelId,
        messageId,
        reaction.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
      )
    ) { [unowned self] data, error in
      if let error = error {
        completion(nil, error)
      }else {
        var returnUsers = [User]()
        let users = data as! [[String: Any]]
        for user in users {
          returnUsers.append(User(self, user))
        }

        completion(returnUsers, nil)
      }
    }
  }

  /**
   Gets a guild's roles

   - parameter guildId: Guild to get roles from
  */
  public func getRoles(
    from guildId: Snowflake,
    then completion: @escaping ([Role]?, RequestError?) -> ()
  ) {
    self.request(.getGuildRoles(guildId)) { data, error in
      if let error = error {
        completion(nil, error)
      }else {
        var returnRoles = [Role]()
        let roles = data as! [[String: Any]]
        for role in roles {
          returnRoles.append(Role(role))
        }

        completion(returnRoles, nil)
      }
    }
  }

  /**
   Gets shard that is handling a guild

   - parameter guildId: Guild to get shard for
  */
  public func getShard(for guildId: Snowflake) -> Int {
    return Int((guildId.rawValue >> 22) % UInt64(self.shardCount))
  }

  /**
   Either get a cached user or restfully get a user

   - parameter userId: User to get
  */
  public func getUser(
    _ userId: Snowflake,
    then completion: @escaping (User?, RequestError?) -> ()
  ) {
    self.request(.getUser(userId)) { [unowned self] data, error in
      if let error = error {
        completion(nil, error)
      }else {
        completion(User(self, data as! [String: Any]), nil)
      }
    }
  }
  
  /**
   Get's the current user's guilds
   
   #### Option Params ####
   
   - **before**: Guild Id to get guilds before this one
   - **after**: Guild Id to get guilds after this one
   - **limit**: Amount of guilds to return (1-100)
   
   - parameter options: Dictionary containing options regarding what kind of guilds are returned, and amount
  */
  public func getUserGuilds(
    with options: [String: Any]? = nil,
    then completion: @escaping ([UserGuild]?, RequestError?) -> ()
  ) {
    self.request(.getCurrentUserGuilds, params: options) { data, error in
      if let error = error {
        completion(nil, error)
      }else {
        var returnGuilds = [UserGuild]()
        let guilds = data as! [[String: Any]]
        for guild in guilds {
          returnGuilds.append(UserGuild(guild))
        }
        
        completion(returnGuilds, nil)
      }
    }
  }
  
  /**
   Gets an array of voice regions from a guild

   - parameter guildId: Guild to get voice regions from
  */
  public func getVoiceRegions(
    from guildId: Snowflake,
    then completion: @escaping ([[String: Any]]?, RequestError?) -> ()
  ) {
    self.request(.getGuildVoiceRegions(guildId)) { data, error in
      completion(data as? [[String: Any]], error)
    }
  }

  /**
   Gets a webhook

   - parameter webhookId: Webhook to get
  */
  public func getWebhook(
    _ webhookId: Snowflake,
    token: String? = nil,
    then completion: @escaping (Webhook?, RequestError?) -> ()
  ) {
    self.request(.getWebhook(webhookId, token)) { [unowned self] data, error in
      if let error = error {
        completion(nil, error)
      }else {
        completion(Webhook(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Gets a channel's webhooks

   - parameter channelId: Channel to get webhooks from
  */
  public func getWebhooks(
    from channelId: Snowflake,
    then completion: @escaping ([Webhook]?, RequestError?) -> ()
  ) {
    self.request(.getChannelWebhooks(channelId)) { [unowned self] data, error in
      if let error = error {
        completion(nil, error)
      }else {
        var returnWebhooks = [Webhook]()
        let webhooks = data as! [[String: Any]]
        for webhook in webhooks {
          returnWebhooks.append(Webhook(self, webhook))
        }
        
        completion(returnWebhooks, nil)
      }
    }
  }

  #if os(macOS) || os(Linux)

  /**
   Joins a voice channel

   - parameter channelId: Channel to connect to
  */
  public func joinVoiceChannel(
    _ channelId: Snowflake,
    then completion: @escaping (VoiceConnection) -> ()
  ) {

    guard let guild = self.getGuild(for: channelId) else { return }

    guard let shardId = guild.shard else { return }

    guard let channel = guild.channels[channelId] else { return }
    
    guard channel.type == .guildVoice else { return }

    let shard = self.shardManager.shards.filter {
      $0.id == shardId
    }[0]

    self.voiceManager.handlers[guild.id] = completion

    shard.joinVoiceChannel(channelId, in: guild.id)
  }

  #endif

  /**
   Kicks a member from a guild

   - parameter userId: Member to kick from server
   - parameter guildId: Guild to remove them from
   - parameter reason: Reason why member was kicked from guild (attached to audit log)
  */
  public func kick(
    _ userId: Snowflake,
    from guildId: Snowflake,
    for reason: String? = nil,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(
      .removeGuildMember(guildId, userId),
      reason: reason
    ) { data, error in
      completion?(error)
    }
  }
  
  /**
   Kills a shard
   
   - parameter id: Id of shard to kill
  */
  public func kill(_ id: Int) {
    self.shardManager.kill(id)
  }
  
  /**
   Leaves a guild

   - parameter guildId: Guild to leave
   */
  public func leaveGuild(
    _ guildId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(.leaveGuild(guildId)) { data, error in
      completion?(error)
    }
  }

  #if os(macOS) || os(Linux)

  /**
   Leaves a voice channel

   - parameter channelId: Channel to disconnect from
  */
  public func leaveVoiceChannel(_ channelId: Snowflake) {

    guard let guild = self.getGuild(for: channelId) else { return }

    guard self.voiceManager.guilds[guild.id] != nil else { return }

    guard let shardId = guild.shard else { return }

    guard let channel = guild.channels[channelId] else { return }

    guard channel.type == .guildVoice else { return }

    let shard = self.shardManager.shards.filter {
      $0.id == shardId
    }[0]

    shard.leaveVoiceChannel(in: guild.id)
  }

  #endif

  /**
   Modifies a guild channel

   #### Options Params ####

   - **name**: Name to give channel
   - **position**: Channel position to set it to
   - **topic**: If a text channel, sets the topic of the text channel
   - **bitrate**: If a voice channel, sets the bitrate for the voice channel
   - **user_limit**: If a voice channel, sets the maximum allowed users in a voice channel

   - parameter channelId: Channel to edit
   - parameter options: Optons to give channel
  */
  public func modifyChannel(
    _ channelId: Snowflake,
    with options: [String: Any] = [:],
    then completion: ((GuildChannel?, RequestError?) -> ())? = nil
  ) {
    self.request(
      .modifyChannel(channelId),
      body: options
    ) { [unowned self] data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        let channelData = data as! [String: Any]
        
        switch channelData["type"] as! Int {
        case 0:
          completion?(GuildText(self, channelData), error)
        case 2:
          completion?(GuildVoice(self, channelData), error)
        case 4:
          completion?(GuildCategory(self, channelData), error)
        default: break
        }
      }
    }
  }

  /**
   Modifies channel positions from a guild

   #### Options Params ####

   Array of the following:

   - **id**: The channel id to modify
   - **position**: The sorting position of the channel

   - parameter guildId: Guild to modify channel positions from
   - parameter options: Preconfigured options to set channel positions to
  */
  public func modifyChannelPositions(
    for guildId: Snowflake,
    with options: [[String: Any]],
    then completion: (([GuildChannel]?, RequestError?) -> ())? = nil
  ) {
    self.request(
      .modifyGuildChannelPositions(guildId),
      body: ["array": options]
    ) { [unowned self] data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        var returnChannels = [GuildChannel]()
        let channels = data as! [[String: Any]]
        for channel in channels {
          switch channel["type"] as! Int {
          case 0:
            returnChannels.append(GuildText(self, channel))
          case 2:
            returnChannels.append(GuildVoice(self, channel))
          case 4:
            returnChannels.append(GuildCategory(self, channel))
          default: break
          }
        }

        completion?(returnChannels, nil)
      }
    }
  }

  /**
   Modifes a Guild Embed

   #### Options Params ####

   - **enabled**: Whether or not embed should be enabled
   - **channel_id**: Snowflake of embed channel

   - parameter guildId: Guild to edit embed in
   - parameter options: Dictionary of options to give embed
  */
  public func modifyEmbed(
    for guildId: Snowflake,
    with options: [String: Any],
    then completion: (([String: Any]?, RequestError?) -> ())? = nil
  ) {
    self.request(.modifyGuildEmbed(guildId), body: options) { data, error in
      completion?(data as? [String: Any], error)
    }
  }

  /**
   Modifies a guild

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

   - parameter guildId: Guild to modify
   - parameter options: Preconfigured options to modify guild with
  */
  public func modifyGuild(
    _ guildId: Snowflake,
    with options: [String: Any],
    then completion: ((Guild?, RequestError?) -> ())? = nil
  ) {
    self.request(
      .modifyGuild(guildId),
      body: options
    ) { [unowned self] data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        completion?(
          Guild(
            self,
            data as! [String: Any],
            self.getShard(for: guildId)
          ), nil)
      }
    }
  }

  /**
   Modifies an integration from a guild

   #### Option Params ####

   - **expire_behavior**: The behavior when an integration subscription lapses (see the [integration](https://discordapp.com/developers/docs/resources/guild#integration-object) object documentation)
   - **expire_grace_period**: Period (in seconds) where the integration will ignore lapsed subscriptions
   - **enable_emoticons**: Whether emoticons should be synced for this integration (twitch only currently), true or false

   - parameter integrationId: Integration to modify
   - parameter guildId: Guild to modify integration from
   - parameter options: Preconfigured options to modify this integration with
  */
  public func modifyIntegration(
    _ integrationId: Snowflake,
    for guildId: Snowflake,
    with options: [String: Any],
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(
      .modifyGuildIntegration(guildId, integrationId),
      body: options
    ) { data, error in
      completion?(error)
    }
  }

  /**
   Modifies a member from a guild

   #### Options Params ####

   - **nick**: The nickname to assign
   - **roles**: Array of role id's that should be assigned to the member
   - **mute**: Whether or not to server mute the member
   - **deaf**: Whether or not to server deafen the member
   - **channel_id**: If the user is connected to a voice channel, assigns them the new voice channel they are to connect.

   - parameter userId: Member to modify
   - parameter guildId: Guild to modify member in
   - parameter options: Preconfigured options to modify member with
  */
  public func modifyMember(
    _ userId: Snowflake,
    in guildId: Snowflake,
    with options: [String: Any],
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(
      .modifyGuildMember(guildId, userId),
      body: options
    ) { data, error in
      completion?(error)
    }
  }

  /**
   Modifies a role from a guild

   #### Options Params ####

   - **name**: The name to assign to the role
   - **permissions**: The bitwise permission integer
   - **color**: RGB int color value to assign to the role
   - **hoist**: Whether or not this role should be hoisted on the member list
   - **mentionable**: Whether or not this role should be mentionable by everyone

   - parameter roleId: Role to modify
   - parameter guildId: Guild to modify role from
   - parameter options: Preconfigured options to modify guild roles with
  */
  public func modifyRole(
    _ roleId: Snowflake,
    for guildId: Snowflake,
    with options: [String: Any],
    then completion: ((Role?, RequestError?) -> ())? = nil
  ) {
    self.request(
      .modifyGuildRole(guildId, roleId),
      body: options
    ) { data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        completion?(Role(data as! [String: Any]), nil)
      }
    }
  }

  /**
   Modifies role positions from a guild

   #### Options Params ####

   Array of the following:

   - **id**: The role id to edit position
   - **position**: The sorting position of the role

   - parameter guildId: Guild to modify role positions from
   - parameter options: Preconfigured options to set role positions to
  */
  public func modifyRolePositions(
    for guildId: Snowflake,
    with options: [[String: Any]],
    then completion: (([Role]?, RequestError?) -> ())? = nil
  ) {
    self.request(
      .modifyGuildRolePositions(guildId),
      body: ["array": options]
    ) { data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        var returnRoles: [Role] = []
        let roles = data as! [[String: Any]]
        for role in roles {
          returnRoles.append(Role(role))
        }

        completion?(returnRoles, nil)
      }
    }
  }

  /**
   Modifies a webhook

   #### Option Params ####

   - **name**: The name given to the webhook
   - **avatar**: The avatar image to give webhook in base 64 string

   - parameter webhookId: Webhook to modify
   - parameter options: Preconfigured options to modify webhook with
  */
  public func modifyWebhook(
    _ webhookId: Snowflake,
    token: String? = nil,
    with options: [String: String],
    then completion: ((Webhook?, RequestError?) -> ())? = nil
  ) {
    self.request(
      .modifyWebhook(webhookId, token),
      body: options
    ) { [unowned self] data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        completion?(Webhook(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Moves a member in a voice channel to another voice channel (if they are in one)

   - parameter userId: User to move
   - parameter guildId: Guild that they're in currently
   - parameter channelId: The Id of the channel to send them to
  */
  public func moveMember(
    _ userId: Snowflake,
    in guildId: Snowflake,
    to channelId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(
      .modifyGuildMember(guildId, userId),
      body: ["channel_id": channelId.description]
    ) { data, error in
      completion?(error)
    }
  }

  /**
   Pins a message to a channel

   - parameter messageId: Message to pin
   - parameter channelId: Channel to pin message in
  */
  public func pin(
    _ messageId: Snowflake,
    in channelId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(
      .addPinnedChannelMessage(channelId, messageId)
    ) { data, error in
      completion?(error)
    }
  }

  /**
   Prunes members for x amount of days in a guild

   - parameter guildId: Guild to prune members in
   - parameter limit: Amount of days for prunned users
  */
  public func pruneMembers(
    in guildId: Snowflake,
    for limit: Int,
    then completion: ((Int?, RequestError?) -> ())? = nil
  ) {
    guard limit > 1 else {
      completion?(
        nil,
        RequestError("Limit you provided was lower than 1 user.")
      )
      return
    }

    self.request(
      .beginGuildPrune(guildId),
      params: ["days": limit]
    ) { data, error in
      completion?((data as! [String: Int])["pruned"], error)
    }
  }

  /**
   Removes a user from a Group DM

   - parameter userId: User to remove from DM
   - parameter groupDMId: Snowflake of Group DM you want to remove user from
  */
  public func removeUser(
    _ userId: Snowflake,
    fromGroupDM groupDMId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(.groupDMRemoveRecipient(groupDMId, userId)) { _, error in
      completion?(error)
    }
  }
  
  /**
   Sends a message to channel
   
   - parameter content: String containing message
   - parameter channelId: Channel to send message to
   */
  public func send(
    _ content: String,
    to channelId: Snowflake,
    then completion: ((Message?, RequestError?) -> ())? = nil
  ) {
    self.request(
      .createMessage(channelId),
      body: ["content": content]
    ) { [unowned self] data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        completion?(Message(self, data as! [String: Any]), nil)
      }
    }
  }
  
  /**
   Sends a message to channel

   #### Content Dictionary Params ####

   - **content**: Message to send
   - **username**: The username the webhook will send with the message
   - **avatar_url**: The url of the user the webhook will send
   - **tts**: Whether or not this message is tts
   - **file**: The url of the image to send
   - **embed**: The embed object to send. Refer to [Embed structure](https://discordapp.com/developers/docs/resources/channel#embed-object)

   - parameter content: Dictionary containing info on message
   - parameter channelId: Channel to send message to
  */
  public func send(
    _ content: [String: Any],
    to channelId: Snowflake,
    then completion: ((Message?, RequestError?) -> ())? = nil
  ) {
    var content = content
    var file: String? = nil

    if let messageFile = content["file"] as? String {
      file = messageFile
      content.removeValue(forKey: "file")
    }

    self.request(
      .createMessage(channelId),
      body: !content.isEmpty ? content : nil,
      file: file
    ) { [unowned self] data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        completion?(Message(self, data as! [String: Any]), nil)
      }
    }
  }
  
  /**
   Sends an embed to channel
   
   - parameter content: Embed to send as message
   - parameter channelId: Channel to send message to
   */
  public func send(
    _ content: Embed,
    to channelId: Snowflake,
    then completion: ((Message?, RequestError?) -> ())? = nil
  ) {
    self.request(
      .createMessage(channelId),
      body: ["embed": content.encode()]
    ) { [unowned self] data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        completion?(Message(self, data as! [String: Any]), nil)
      }
    }
  }
  
  /**
   Sets bot to typing in channel

   - parameter channelId: Channel to set typing to
  */
  public func setTyping(
    for channelId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(.triggerTypingIndicator(channelId)) { data, error in
      completion?(error)
    }
  }

  /**
   Sets bot's username

   - parameter name: Name to set bot's username to
  */
  public func setUsername(
    to name: String,
    then completion: ((User?, RequestError?) -> ())? = nil
  ) {
    self.request(
      .modifyCurrentUser,
      body: ["username": name]
    ) { [unowned self] data, error in
      if let error = error {
        completion?(nil, error)
      }else {
        completion?(User(self, data as! [String: Any]), nil)
      }
    }
  }
  
  /**
   Used to spawn a shard
   
   - parameter id: Id of shard to spawn
  */
  public func spawn(_ id: Int) {
    self.shardManager.spawn(id)
  }
  
  /**
   Syncs an integration for a guild

   - parameter integrationId: Integration to sync
   - parameter guildId: Guild to sync intregration for
  */
  public func syncIntegration(
    _ integrationId: Snowflake,
    for guildId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(.syncGuildIntegration(guildId, integrationId)) { data, error in
      completion?(error)
    }
  }

  /**
   Unbans a user from this guild

   - parameter userId: User to unban
  */
  public func unbanMember(
    _ userId: Snowflake,
    from guildId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(.removeGuildBan(guildId, userId)) { data, error in
      completion?(error)
    }
  }

  /**
   Unpins a pinned message from a channel

   - parameter messageId: Pinned message to unpin
  */
  public func unpin(
    _ messageId: Snowflake,
    from channelId: Snowflake,
    then completion: ((RequestError?) -> ())? = nil
  ) {
    self.request(
      .deletePinnedChannelMessage(channelId, messageId)
    ) { data, error in
      completion?(error)
    }
  }

}
