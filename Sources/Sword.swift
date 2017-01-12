//
//  Sword.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2016 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Main Class for Sword
public class Sword {

  // MARK: Properties

  /// Endpoints structure
  let endpoints = Endpoints()

  /// Eventer class
  let eventer = Eventer()

  /// The gateway url to connect to
  var gatewayUrl: String?

  /// Array of guilds the bot is currently connected to
  public var guilds: [String: Guild] = [:]

  /// Optional options to apply to bot
  var options: SwordOptions

  /// Timestamp of ready event
  public internal(set) var readyTimestamp: Date?

  /// Requester class
  let requester: Request

  /// Amount of shards to initialize
  public var shardCount = 1

  /// Array of Shard class
  var shards: [Shard] = []

  /// The bot token
  let token: String

  /// Array of unavailable guilds the bot is currently connected to
  public var unavailableGuilds: [String: UnavailableGuild] = [:]

  public var uptime: Date? {
    if self.readyTimestamp != nil {
      return Date() - self.readyTimestamp!.timeIntervalSince1970
    }else {
      return nil
    }
  }

  /// The user account for the bot
  public var user: User?

  // MARK: Initializer

  /**
   Initializes the Sword class

   - parameter token: The bot token
   - parameter options: Options to give bot (sharding, offline members, etc)
   */
  public init(token: String, with options: SwordOptions = SwordOptions()) {
    self.options = options
    self.requester = Request(token)
    self.token = token
  }

  // MARK: Functions

  /**
   Listens for events

   - parameter eventName: The event to listen for
   - parameter completion: Code block to execute when the event is fired
   */
  public func on(_ eventName: String, _ completion: @escaping ([Any]) -> ()) {
    self.eventer.on(eventName, completion)
  }

  /**
   Emits listeners for event

   - parameter eventName: The event to emit listeners for
   - parameter data: Variadic set of Any(s) to send to listener
   */
  public func emit(_ eventName: String, with data: Any...) {
    self.eventer.emit(eventName, with: data)
  }

  /// Gets the gateway URL to connect to
  func getGateway(completion: @escaping (Error?, [String: Any]?) -> ()) {
    self.requester.request(self.endpoints.gateway, rateLimited: false) { error, data in
      if error != nil {
        completion(error, nil)
        return
      }

      guard let data = data as? [String: Any] else {
        completion(.unknown, nil)
        return
      }

      completion(nil, data)
    }
  }

  /// Starts the bot
  public func connect() {
    self.getGateway() { error, data in
      if error != nil {
        print(error!)
        sleep(2)
        self.connect()
      }else {
        self.gatewayUrl = "\(data!["url"]!)/?encoding=json&v=6"
        self.shardCount = data!["shards"] as! Int

        for id in 0..<self.shardCount {
          let shard = Shard(self, id, self.shardCount)
          self.shards.append(shard)
          shard.startWS(self.gatewayUrl!)
        }

      }
    }
  }

  /**
   Adds a user to guild

   - parameter userId: User to add
   - parameter guildId: The guild to add user in
   - parameter options: Initial options to equip user with in guild
   */
  public func add(user userId: String, to guildId: String, with options: [String: Any] = [:], _ completion: @escaping (Member?) -> () = {_ in}) {
    self.requester.request(endpoints.addGuildMember(guildId, userId), body: options.createBody(), method: "PUT") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Member(self, data as! [String: Any]))
      }
    }
  }

  /**
   Creates an invite for channel

   - parameter channelId: Channel to create invite for
   - parameter options: Options to give invite
   */
  public func createInvite(for channelId: String, with options: [String: Any] = [:], _ completion: @escaping (Any?) -> () = {_ in}) {
    self.requester.request(endpoints.createChannelInvite(channelId), body: options.createBody(), method: "POST") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data)
      }
    }
  }

  /**
   Deletes a channel

   - parameter channelId: Channel to delete
   */
  public func delete(channel channelId: String, _ completion: @escaping (Any?) -> () = {_ in}) {
    self.requester.request(endpoints.deleteChannel(channelId), method: "DELETE") { error, data in
      if error != nil {
        completion(nil)
      }else {
        let channelData = data as! [String: Any]
        if channelData["recipient"] == nil {
          completion(Channel(self, channelData))
        }else {
          completion(DMChannel(self, channelData))
        }
      }
    }
  }

  /**
   Deletes a guild

   - parameter guildId: Guild to delete
   */
  public func delete(guild guildId: String, _ completion: @escaping (Guild?) -> () = {_ in}) {
    self.requester.request(endpoints.deleteGuild(guildId), method: "DELETE") { error, data in
      if error != nil {
        completion(nil)
      }else {
        let guild = Guild(self, data as! [String: Any])
        self.guilds.removeValue(forKey: guild.id)
        completion(guild)
      }
    }
  }

  /**
   Deletes an invite

   - parameter inviteId: Invite to delete
   */
  public func delete(invite inviteId: String, _ completion: @escaping (Any?) -> () = {_ in}) {
    self.requester.request(endpoints.deleteInvite(inviteId), method: "DELETE") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as! [String: Any])
      }
    }
  }

  /**
   Deletes a webhook

   - parameter webhookId: Webhook to delete
   */
  public func delete(webhook webhookId: String, _ completion: @escaping () -> () = {_ in}) {
    self.requester.request(endpoints.deleteWebhook(webhookId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Deletes an overwrite permission for a channel

   - parameter channelId: Channel to delete permissions from
   - parameter overwriteId: Overwrite ID to use for permissons
   */
  public func deletePermission(for channelId: String, with overwriteId: String, _ completion: @escaping () -> () = {_ in}) {
    self.requester.request(endpoints.deleteChannelPermission(channelId, overwriteId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Edits a channel

   - parameter channelId: Channel to edit
   - parameter options: Optons to give channel
   */
  public func edit(channel channelId: String, with options: [String: Any] = [:], _ completion: @escaping (Channel?) -> () = {_ in}) {
    self.requester.request(endpoints.modifyChannel(channelId), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Channel(self, data as! [String: Any]))
      }
    }
  }

  /**
   Edits a channel's overwrite permission

   - parameter permissions: ["allow": perm#, "deny": perm#, "type": "role" || "member"]
   - parameter channelId: Channel to edit permissions for
   - parameter overwriteId: Overwrite ID to use for permissions
   */
  public func edit(permissions: [String: Any], for channelId: String, with overwriteId: String, _ completion: @escaping () -> () = {_ in}) {
    self.requester.request(endpoints.editChannelPermissions(channelId, overwriteId), body: permissions.createBody(), method: "PUT") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Edits bot status

   - parameter status: Status to set bot to. Either "online" (default), "idle", "dnd", "invisible"
   - parameter game: ["name": "with Swords!", "type": 0 || 1]
   */
  public func editStatus(to status: String = "online", playing game: [String: Any]? = nil) {
    guard self.shards.count > 0 else { return }
    var data: [String: Any] = ["afk": status == "idle", "game": NSNull(), "since": status == "idle" ? Date().milliseconds : 0, "status": status]

    if game != nil {
      data["game"] = game
    }

    let payload = Payload(op: .statusUpdate, data: data).encode()

    for shard in self.shards {
      shard.send(payload, presence: true)
    }
  }

  /**
   Executes a webhook

   - parameter webhookId: Webhook to execute
   - parameter webhookToken: Token for auth to execute
   - parameter content: String or dictionary containing message content
   */
  public func execute(webhook webhookId: String, token webhookToken: String, with content: Any, _ completion: @escaping () -> () = {_ in}) {
    guard let message = content as? [String: Any] else {
      let data = ["content": content].createBody()
      self.requester.request(endpoints.executeWebhook(webhookId, webhookToken), body: data, method: "POST") { error, data in
        if error == nil { completion() }
      }
      return
    }
    var file: [String: Any] = [:]
    var parameters: [String: String] = [:]

    if message["file"] != nil {
      file["file"] = message["file"] as! String
    }
    if message["content"] != nil {
      parameters["content"] = (message["content"] as! String)
    }
    if message["tts"] != nil {
      parameters["tts"] = (message["tts"] as! String)
    }
    if message["embed"] != nil {
      parameters["payload_json"] = (message["embed"] as! [String: Any]).encode()
    }
    if message["username"] != nil {
      parameters["username"] = (message["user"] as! String)
    }
    if message["avatar_url"] != nil {
      parameters["avatar_url"] = (message["avatar_url"] as! String)
    }

    file["parameters"] = parameters

    self.requester.request(endpoints.executeWebhook(webhookId, webhookToken), file: file, method: "POST") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Executs a slack style webhook

   - parameter webhookId: Webhook to execute
   - parameter webhookToken: Token for auth to execute
   */
  public func executeSlack(webhook webhookId: String, token webhookToken: String, with content: [String: Any], _ completion: @escaping () -> () = {_ in}) {
    self.requester.request(endpoints.executeSlackWebhook(webhookId, webhookToken), body: content.createBody(), method: "POST") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Gets a message from channel

   - parameter messageId: Message to get
   - parameter channelId: Channel to get message from
   */
  public func get(message messageId: String, from channelId: String, _ completion: @escaping (Message?) -> () = {_ in}) {
    self.requester.request(endpoints.getChannelMessage(channelId, messageId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Message(self, data as! [String: Any]))
      }
    }
  }

  /**
   Gets an array of messages from channel

   - parameter limit: Amount of messages to get
   - parameter channelId: Channel to get messages from
   */
  public func get(_ limit: Int, messagesFrom channelId: String, _ completion: @escaping ([Message]?) -> () = {_ in}) {
    if limit > 100 || limit < 1 { completion(nil); return }
    self.requester.request(endpoints.getChannelMessages(channelId), body: ["limit": limit].createBody()) { error, data in
      if error != nil {
        completion(nil)
      }else {
        var returnMessages: [Message] = []
        let messages = data as! [[String: Any]]
        for message in messages {
          returnMessages.append(Message(self, message))
        }
        completion(returnMessages)
      }
    }
  }

  /**
   Gets an invite

   - parameter inviteId: Invite to get
   */
  public func get(invite inviteId: String, _ completion: @escaping (Any?) -> () = {_ in}) {
    self.requester.request(endpoints.getInvite(inviteId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as! [String: Any])
      }
    }
  }

  /**
   Gets a user from guild

   - parameter userId: User to get
   - parameter guildId: Guild to get user from
   */
  public func get(user userId: String, from guildId: String, _ completion: @escaping (Member?) -> () = {_ in}) {
    self.requester.request(endpoints.getGuildMember(guildId, userId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        let member = Member(self, data as! [String: Any])
        completion(member)
      }
    }
  }

  /**
   Gets a webhook

   - parameter webhookId: Webhook to get
   */
  public func get(webhook webhookId: String, _ completion: @escaping ([String: Any]?) -> ()) {
    self.requester.request(endpoints.getWebhook(webhookId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as? [String: Any])
      }
    }
  }

  /**
   Gets a channel's invites

   - parameter channelId: Channel to get invites from
   */
  public func getInvites(for channelId: String, _ completion: @escaping (Any?) -> () = {_ in}) {
    self.requester.request(endpoints.getChannelInvites(channelId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data)
      }
    }
  }

  /**
   Restfully gets a channel

   - parameter channelId: Channel to get restfully
   */
  public func getREST(channel channelId: String, _ completion: @escaping (Any?) -> ()) {
    self.requester.request(endpoints.getChannel(channelId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        let channelData = data as! [String: Any]
        if channelData["recipient"] == nil {
          completion(Channel(self, channelData))
        }else {
          completion(DMChannel(self, channelData))
        }
      }
    }
  }

  /**
   Restfully gets a guild

   - parameter guildId: Guild to get restfully
   */
  public func getREST(guild guildId: String, _ completion: @escaping (Guild?) -> ()) {
    self.requester.request(endpoints.getGuild(guildId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        let guild = Guild(self, data as! [String: Any])
        self.guilds[guild.id] = guild
        completion(guild)
      }
    }
  }

  /**
   Restfully gets a user

   - parameter userId: User to get restfully
   */
  public func getREST(user userId: String, _ completion: @escaping (User?) -> ()) {
    self.requester.request(endpoints.getUser(userId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(User(self, data as! [String: Any]))
      }
    }
  }

  /**
   Restfully gets channels from guild

   - parameter guildId: Guild to get channels from
   */
  public func getRESTChannels(from guildId: String, _ completion: @escaping ([Channel]?) -> ()) {
    self.requester.request(endpoints.getGuildChannels(guildId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        var returnChannels: [Channel] = []
        let channels = data as! [[String: Any]]
        for channel in channels {
          returnChannels.append(Channel(self, channel))
        }

        completion(returnChannels)
      }
    }
  }

  /// Restfully get guilds bot is in
  public func getRESTGuilds(_ completion: @escaping ([[String: Any]]?) -> ()) {
    self.requester.request(endpoints.getCurrentUserGuilds()) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as? [[String: Any]])
      }
    }
  }

  /**
   Leaves a guild

   - parameter guildId: Guild to leave
   */
  public func leave(guild guildId: String, _ completion: @escaping () -> () = {_ in}) {
    self.requester.request(endpoints.leaveGuild(guildId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Modifies a webhook

   - parameter webhookId: Webhook to modify
   - parameter options: ["name": "name of webhook", "avatar": "img data in base64"]
   */
  public func modify(webhook webhookId: String, with options: [String: String], _ completion: @escaping ([String: Any]?) -> () = {_ in}) {
    self.requester.request(endpoints.modifyWebhook(webhookId), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as? [String: Any])
      }
    }
  }

  /**
   Sends a message to channel

   - parameter content: Either string or dictionary containing info on message
   - parameter channelId: Channel to send message to
   */
  public func send(_ content: Any, to channelId: String, _ completion: @escaping (Message?) -> () = {_ in}) {
    guard let message = content as? [String: Any] else {
      let data = ["content": content].createBody()
      self.requester.request(endpoints.createMessage(channelId), body: data, method: "POST") { error, data in
        if error != nil {
          completion(nil)
        }else {
          completion(Message(self, data as! [String: Any]))
        }
      }
      return
    }
    var file: [String: Any] = [:]
    var parameters: [String: String] = [:]

    if message["file"] != nil {
      file["file"] = message["file"] as! String
    }
    if message["content"] != nil {
      parameters["content"] = (message["content"] as! String)
    }
    if message["tts"] != nil {
      parameters["tts"] = (message["tts"] as! String)
    }
    if message["embed"] != nil {
      parameters["payload_json"] = (message["embed"] as! [String: Any]).encode()
    }

    file["parameters"] = parameters

    self.requester.request(endpoints.createMessage(channelId), file: file, method: "POST") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Message(self, data as! [String: Any]))
      }
    }
  }

  /**
   Sets bot to typing in channel

   - parameter channelId: Channel to set typing to
   */
  public func setTyping(for channelId: String, _ completion: @escaping () -> () = {_ in}) {
    self.requester.request(endpoints.triggerTypingIndicator(channelId), method: "POST") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Sets bot's username

   - parameter name: Name to set bot's username to
   */
  public func setUsername(to name: String, _ completion: @escaping (User?) -> () = {_ in}) {
    self.requester.request(endpoints.modifyCurrentUser(), body: ["username": name].createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(nil)
      }else {
        let user = User(self, data as! [String: Any])
        self.user = user
        completion(user)
      }
    }
  }

}
