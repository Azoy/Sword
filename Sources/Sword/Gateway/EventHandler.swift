//
//  EventHandler.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Create a nifty Event Emitter in Swift
public protocol EventHandler: AnyObject {
  /// Event Listeners
  var listeners: [Event: [Any]] { get set }
}

extension EventHandler {
  /// Listens for event
  ///
  /// - parameter event: Event to listen for
  func on(_ event: Event, do function: Any) {
    guard listeners.keys.contains(event) else {
      listeners[event] = [function]
      return
    }
    
    listeners[event]?.append(function)
  }
}

extension EventHandler where Self == Sword {
  /// Listens for when a guild is available
  public func onGuildAvailable(do function: @escaping (Guild) -> ()) {
    on(.guildAvailable, do: function)
  }
  
  /// Listens for GUILD_CREATE events
  public func onGuildCreate(do function: @escaping (Guild) -> ()) {
    on(.guildCreate, do: function)
  }
  
  /// Listens for PRESENCE_UPDATE events
  public func onPresenceUpdate(do function: @escaping (Presence) -> ()) {
    on(.presenceUpdate, do: function)
  }
  
  /// Listens for READY events
  public func onReady(do function: @escaping (User) -> ()) {
    on(.ready, do: function)
  }
  
  /// Emits all listeners for when a guild is available
  ///
  /// - parameter guild: Guild to emit listener with
  public func emitGuildAvailable(_ guild: Guild) {
    guard let listeners = listeners[.guildAvailable] else { return }
    
    for listener in listeners {
      let listener = listener as! (Guild) -> ()
      listener(guild)
    }
  }
  
  /// Emits all listeners for GUILD_CREATE
  ///
  /// - parameter guild: Guild to emit listener with
  public func emitGuildCreate(_ guild: Guild) {
    guard let listeners = listeners[.guildCreate] else { return }
    
    for listener in listeners {
      let listener = listener as! (Guild) -> ()
      listener(guild)
    }
  }
  
  /// Emits all listeners for PRESENCE_UPDATE
  ///
  /// - parameter presence: Presence to emit listener with
  public func emitPresenceUpdate(_ presence: Presence) {
    guard let listeners = listeners[.presenceUpdate] else { return }
    
    for listener in listeners {
      let listener = listener as! (Presence) -> ()
      listener(presence)
    }
  }
  
  /// Emits all listeners for READY
  ///
  /// - parameter data: User to emit listener with
  public func emitReady(_ user: User) {
    guard let listeners = listeners[.ready] else { return }
    
    for listener in listeners {
      let listener = listener as! (User) -> ()
      listener(user)
    }
  }
}
