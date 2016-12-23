import Foundation

public class Sword {

  let token: String

  let requester: Request
  let endpoints = Endpoints()
  var shards: [Shard] = []
  let eventer = Eventer()

  var gatewayUrl: String?
  var shardCount: Int?

  public var guilds: [String: Guild] = [:]
  public var unavailableGuilds: [String: UnavailableGuild] = [:]
  public var user: User?

  /* Sword Initializer
    @param token: String - Bot Token
  */
  public init(token: String) {
    self.token = token
    self.requester = Request(token)
  }

  // Alias for Eventer().on(_:, _:)
  public func on(_ eventName: String, _ completion: @escaping (_ data: Any) -> ()) {
    self.eventer.on(eventName, completion)
  }

  // Alias for Eventer().emit(_:, with:)
  public func emit(_ eventName: String, with data: Any...) {
    self.eventer.emit(eventName, with: data)
  }

  // Used to get gateway URL
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

  // Starts WS with Discord
  public func connect() {
    self.getGateway() { error, data in
      if error != nil {
        print(error!)
        sleep(2)
        self.connect()
      }else {
        self.gatewayUrl = "\(data!["url"]!)/?encoding=json&v=6"
        self.shardCount = data!["shards"] as? Int

        for id in 0..<self.shardCount! {
          let shard = Shard(self, id, self.shardCount!)
          self.shards.append(shard)
          shard.startWS(self.gatewayUrl!)
        }

      }
    }
  }

  /* Add User to Guild
    @param userId: String - User to add to guild
    @param guildId: String - Guild to add user in
    @param options: [String: Any] - Options to give new member
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

  /* Creates an invite for channel
    @param channelId: String - Channel to create invite for
    @param options: [String: Any] - Options for invite
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

  /* Deletes a channel
    @param channelId: String - Channel to delete
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

  /* Delete an invite
    @param inviteId: String - ID of invite
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

  /* Deletes permissions for overwrite in channel
    @param channelId: String - Channel to delete permisson from
    @param overwriteId: String - Overwrite to delete
  */
  public func deletePermission(for channelId: String, with overwriteId: String, _ completion: @escaping () -> () = {_ in}) {
    self.requester.request(endpoints.deleteChannelPermission(channelId, overwriteId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /* Edits channel with options
    @param channelId: String - Channel to edit
    @param options: [String: Any] - Options to append to channel
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

  /* Edits permissions for channel
    @param permissions: [String: Any] - Permissions to add/remove from channel
    @param channelId: String - Channel to edit perms for
    @param overwriteId: String - Overwrite id to change perms for
  */
  public func edit(permissions: [String: Any], for channelId: String, with overwriteId: String, _ completion: @escaping () -> () = {_ in}) {
    self.requester.request(endpoints.editChannelPermissions(channelId, overwriteId), body: permissions.createBody(), method: "PUT") { error, data in
      if error == nil { completion() }
    }
  }

  /* Edits status
    @param status: String - "online" | "idle" | "dnd" | "invisible"
    @param game: [String: Any]? - Game to set status to/set streaming
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

  /* Get message from channel
    @param messageId: String - Message to get
    @param channelId: String - Channel to get message from
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

  /* Gets messages from channel
    @param limit: Int - Amount of messages to get
    @param channelId: String - Channel to get messages from
  */
  public func get(_ limit: Int, messagesFrom channelId: String, _ completion: @escaping ([Message]?) -> () = {_ in}) {
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

  /* Get an invite
    @param inviteId: String - ID of invite
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

  /* Gets channel invites
    @param channelId: String - Channel to get invites from
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

  /* Restfully get channel
    @param channelId: String - Channel to get
  */
  public func getREST(channel channelId: String, _ completion: @escaping (Any?) -> () = {_ in}) {
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

  /* Send message to channel
    @param content: Any - Either a string or a dictionary with info on embeds, files, tts, etc..
    @param channelId: String - Channel to send message to
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

    file["file"] = message["file"] as! String

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

  /* Sets bot to typing in channel
    @param channelId: String - Channel to start "typing" in
  */
  public func setTyping(for channelId: String, _ completion: @escaping () -> () = {_ in}) {
    self.requester.request(endpoints.triggerTypingIndicator(channelId), method: "POST") { error, data in
      if error == nil { completion() }
    }
  }

  /* Sets bot's username
    @param name: String - Name to change to
  */
  public func setUsername(to name: String, _ completion: (_ data: User) -> () = {_ in}) {

  }

}
