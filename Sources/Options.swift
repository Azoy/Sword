public struct SwordOptions {

  public let isCacheAllMembers: Bool

  public let cacheMessageLimit: Int

  public let disabledEvents: [String]

  public let isSharded: Bool

  public init(cacheAllMembers: Bool = false, cacheMessageLimit: Int = 50, disabledEvents: [String] = [], sharded: Bool = true) {
    self.isCacheAllMembers = cacheAllMembers
    self.cacheMessageLimit = cacheMessageLimit
    self.disabledEvents = disabledEvents
    self.isSharded = sharded
  }

}

public struct ShieldOptions {

  public internal(set) var prefixes: [String]

  public init(prefixes: [String] = ["@bot"]) {
    self.prefixes = prefixes
  }

}

public struct CommandOptions {

  public let aliases: [String]

  public let isCaseSensitive: Bool

  public init(aliases: [String] = [], caseSensitive: Bool = false) {
    self.aliases = aliases
    self.isCaseSensitive = caseSensitive
  }

}
