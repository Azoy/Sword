//
//  EventHandler.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

public enum EventHandler {
  public static var channelCreate: (Channel) -> () = { _ in }
  
  public static var guildAvailable: (Guild) -> () = { _ in }
  
  public static var guildCreate: (Guild) -> () = { _ in }
  
  public static var presenceUpdate: (Presence) -> () = { _ in }
  
  public static var ready: (User) -> () = { _ in }
  
  public static var typingStart: (Typing) -> () = { _ in }
}
