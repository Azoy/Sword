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

  public init(token: String) {
    self.token = token
    self.requester = Request(token)
  }

  public func on(_ eventName: String, _ completion: @escaping (_ data: Any) -> ()) {
    self.eventer.on(eventName, completion)
  }

  public func emit(_ eventName: String, with data: Any...) {
    self.eventer.emit(eventName, with: data)
  }

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

  public func add(user userId: String, to guildId: String, with options: [String: Any] = [:], _ completion: @escaping (Member?) -> () = {_ in}) {
    self.requester.request(endpoints.addGuildMember(guildId, userId), body: options.createBody(), method: "PUT") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Member(self, data as! [String: Any]))
      }
    }
  }

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

  public func edit(channel channelId: String, options: [String: Any] = [:], _ completion: @escaping (Channel?) -> () = {_ in}) {
    self.requester.request(endpoints.modifyChannel(channelId), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Channel(self, data as! [String: Any]))
      }
    }
  }

  public func edit(permissions: [String: Any], for channelId: String, with overwriteId: String, _ completion: @escaping () -> () = {_ in}) {
    
  }

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

  public func get(message messageId: String, from channelId: String, _ completion: @escaping (Message?) -> () = {_ in}) {
    self.requester.request(endpoints.getChannelMessage(channelId, messageId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Message(self, data as! [String: Any]))
      }
    }
  }

  public func getMessages(from channelId: String, _ completion: @escaping ([Message]?) -> () = {_ in}) {
    self.requester.request(endpoints.getChannelMessages(channelId)) { error, data in
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

  public func setUsername(to name: String, _ completion: (_ data: User) -> () = {_ in}) {

  }

}
