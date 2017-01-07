//
//  Options.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2016 Alejandro Alonso. All rights reserved.
//

import Foundation

/// SwordOptions Type
public struct SwordOptions {

  // MARK: Propterties

  /// Whether or not the bot is sharding
  let isSharding: Bool

  /// Whether or not the bot is caching offline guild members
  let isCachingOfflineMembers: Bool

  // MARK: Initializer

  /**
   Creates a SwordOptions structure

   - parameter sharding: Whether or not the bot should be sharding
   - parameter cacheOfflineMembers: Whether or not the should be caching offline guild members
  */
  public init(sharding: Bool = true, cacheOfflineMembers: Bool = false) {
    self.isSharding = sharding
    self.isCachingOfflineMembers = cacheOfflineMembers
  }

}

/// ShieldOptions Type
public struct ShieldOptions {

  // MARK: Properties

  /// An array of prefixes the bot should listen for
  let prefixes: [String]

  // MARK: Initializer

  /**
   Crates a ShieldOptions structure

   - parameter prefixes: Array of strings the command should be prefixed with
  */
  public init(prefixes: [String] = ["@mention "]) {
    self.prefixes = prefixes
  }

}
