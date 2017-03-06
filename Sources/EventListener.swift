//
//  EventListener.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

public struct EventListener {

  var listeners: [Event: [Any]] = [:]

  mutating func add(_ function: Any, to event: Event) {
    guard self.listeners[event] != nil else {
      self.listeners[event] = [function]
      return
    }
    self.listeners[event]!.append(function)
  }

  public mutating func audioData(do function: @escaping (Data) -> ()) {
    self.add(function, to: .audioData)
  }

  public mutating func channelCreate(do function: @escaping (Channel) -> ()) {
    self.add(function, to: .channelCreate)
  }

  public mutating func channelDelete(do function: @escaping (Channel) -> ()) {
    self.add(function, to: .channelDelete)
  }

  public mutating func channelUpdate(do function: @escaping (Channel) -> ()) {
    self.add(function, to: .channelUpdate)
  }

  public mutating func connectionClose(do function: @escaping () -> ()) {
    self.add(function, to: .connectionClose)
  }

  public mutating func guildAvailable(do function: @escaping (Guild) -> ()) {
    self.add(function, to: .guildAvailable)
  }

  public mutating func guildBanAdd(do function: @escaping (Guild, User) -> ()) {
    self.add(function, to: .guildBanAdd)
  }

  public mutating func guildBanRemove(do function: @escaping (Guild, User) -> ()) {
    self.add(function, to: .guildBanRemove)
  }

  public mutating func guildCreate(do function: @escaping (Guild) -> ()) {
    self.add(function, to: .guildCreate)
  }

  public mutating func guildDelete(do function: @escaping (Guild) -> ()) {
    self.add(function, to: .guildDelete)
  }

  public mutating func guildEmojisUpdate(do function: @escaping (Guild, [Emoji]) -> ()) {
    self.add(function, to: .guildEmojisUpdate)
  }

  public mutating func guildIntegrationsUpdate(do function: @escaping (Guild) -> ()) {
    self.add(function, to: .guildIntegrationsUpdate)
  }

  public mutating func guildMemberAdd(do function: @escaping (Guild, Member) -> ()) {
    self.add(function, to: .guildMemberAdd)
  }

  public mutating func guildMemberRemove(do function: @escaping (Guild, User) -> ()) {
    self.add(function, to: .guildMemberRemove)
  }

  public mutating func guildMemberUpdate(do function: @escaping (Member) -> ()) {
    self.add(function, to: .guildMemberUpdate)
  }

  public mutating func guildRoleCreate(do function: @escaping (Guild, Role) -> ()) {
    self.add(function, to: .guildRoleCreate)
  }

  public mutating func guildRoleDelete(do function: @escaping (Guild, Role) -> ()) {
    self.add(function, to: .guildRoleDelete)
  }

  public mutating func guildRoleUpdate(do function: @escaping (Guild, Role) -> ()) {
    self.add(function, to: .guildRoleUpdate)
  }

  public mutating func guildUnavailable(do function: @escaping (UnavailableGuild) -> ()) {
    self.add(function, to: .guildUnavailable)
  }

  public mutating func guildUpdate(do function: @escaping (Guild) -> ()) {
    self.add(function, to: .guildUpdate)
  }

  public mutating func messageCreate(do function: @escaping (Message) -> ()) {
    self.add(function, to: .messageCreate)
  }

  public mutating func messageDelete(do function: @escaping (Message, Channel) -> ()) {
    self.add(function, to: .messageDelete)
  }

  public mutating func messageDeleteBulk(do function: @escaping ([Any], Channel) -> ()) {
    self.add(function, to: .messageDeleteBulk)
  }

  public mutating func messageUpdate(do function: @escaping ([String: Any]) -> ()) {
    self.add(function, to: .messageUpdate)
  }

  public mutating func presenceUpdate(do function: @escaping (String, Presence) -> ()) {
    self.add(function, to: .presenceUpdate)
  }

  public mutating func ready(do function: @escaping (User) -> ()) {
    self.add(function, to: .ready)
  }

  public mutating func typingStart(do function: @escaping (Channel, String, Date) -> ()) {
    self.add(function, to: .typingStart)
  }

  public mutating func userUpdate(do function: @escaping (User) -> ()) {
    self.add(function, to: .userUpdate)
  }

  public mutating func voiceChannelJoin(do function: @escaping (String, VoiceState) -> ()) {
    self.add(function, to: .voiceChannelJoin)
  }

  public mutating func voiceChannelLeave(do function: @escaping (String) -> ()) {
    self.add(function, to: .voiceChannelLeave)
  }

  public mutating func voiceStateUpdate(do function: @escaping (String) -> ()) {
    self.add(function, to: .voiceStateUpdate)
  }

}
