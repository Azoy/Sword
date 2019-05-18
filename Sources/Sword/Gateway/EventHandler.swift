//
//  EventHandler.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

enum EventEmitter {
  static var channelCreate: (Channel) -> () = { _ in }
  
  static var guildAvailable: (Guild) -> () = { _ in }
  
  static var guildCreate: (Guild) -> () = { _ in }
  
  static var messageCreate: (Message) -> () = { _ in }
  
  static var presenceUpdate: (Presence) -> () = { _ in }
  
  static var ready: (User) -> () = { _ in }
  
  static var typingStart: (Typing) -> () = { _ in }
}

public enum EventHandler {
  public static func channelCreate(_ handler: @escaping (Channel) -> ()) {
    EventEmitter.channelCreate = handler
  }
  
  public static func guildAvailable(_ handler: @escaping (Guild) -> ()) {
    EventEmitter.guildAvailable = handler
  }
  
  public static func guildCreate(_ handler: @escaping (Guild) -> ()) {
    EventEmitter.guildCreate = handler
  }
  
  public static func messageCreate(_ handler: @escaping (Message) -> ()) {
    EventEmitter.messageCreate = handler
  }
  
  public static func presenceUpdate(_ handler: @escaping (Presence) -> ()) {
    EventEmitter.presenceUpdate = handler
  }
  
  public static func ready(_ handler: @escaping (User) -> ()) {
    EventEmitter.ready = handler
  }
  
  public static func typingStart(_ handler: @escaping (Typing) -> ()) {
    EventEmitter.typingStart = handler
  }
}
