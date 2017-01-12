public struct SwordOptions {

  public let isCacheAllMembers = false

  public let cacheMessageLimit = 50

  public let disabledEvents: [String] = []

  public let isSharded = true

}

public struct ShieldOptions {

  public internal(set) var prefixes: [String] = ["@bot "]

}
