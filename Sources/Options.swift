public struct SwordOptions {

  public var isCacheAllMembers: Bool

  public var cacheMessageLimit: Int

  public var disabledEvents: [String]

  public var isSharded: Bool

  public init(cacheAllMembers: Bool = false, cacheMessageLimit: Int = 50, disabledEvents: [String] = [], sharded: Bool = true) {
    self.isCacheAllMembers = cacheAllMembers
    self.cacheMessageLimit = cacheMessageLimit
    self.disabledEvents = disabledEvents
    self.isSharded = sharded
  }

}

public struct ShieldOptions {

  public var prefixes: [String]

  public init(prefixes: [String] = ["@bot"]) {
    self.prefixes = prefixes
  }

}

public struct CommandOptions {

  public var aliases: [String]

  public init(aliases: [String] = []) {
    self.aliases = aliases
  }

}
