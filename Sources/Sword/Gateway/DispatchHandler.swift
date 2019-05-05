//
//  DispatchHandler.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation

extension Shard {
  /// Operates on a given dispatch payload
  ///
  /// - parameter payload: Payload received from gateway
  /// - parameter ws: WebSocket session
  func handleDispatch(
    _ payload: PayloadSinData,
    _ data: Data
  ) {
    // Make sure we got an event name
    guard let t = payload.t else {
      Sword.log(.warning, .dispatchName(id))
      return
    }
    
    // Make sure we can handle this event
    guard let event = Event(rawValue: t) else {
      Sword.log(.warning, .unknownEvent(t))
      return
    }
    
    // Handle the event
    switch event {
    // CHANNEL_CREATE
    case .channelCreate:
      guard let channelDecoding
          = decode(ChannelDecoding.self, from: data) else {
        Sword.log(.warning, "Could not decode channel")
        return
      }
      
      let channel: Channel
      
      switch channelDecoding.type {
      case .guildCategory:
        guard let tmp = decode(Guild.Channel.Category.self, from: data) else {
          Sword.log(.warning, "Could not decode channel")
          return
        }
        
        channel = tmp
        
      case .guildText:
        guard let tmp = decode(Guild.Channel.Text.self, from: data) else {
          Sword.log(.warning, "Could not decode channel")
          return
        }
        
        channel = tmp
        
      case .guildVoice:
        guard let tmp = decode(Guild.Channel.Voice.self, from: data) else {
          Sword.log(.warning, "Could not decode channel")
          return
        }
        
        channel = tmp
        
      default:
        // FIXME: When I implement the other channel types decode them here
        return
      }
      
      sword.on.channelCreate(channel)
      
    // GUILD_CREATE
    case .guildCreate:
      Sword.decoder.dateDecodingStrategy = .custom(decodeISO8601)
      guard let guild = decode(Guild.self, from: data) else {
        Sword.log(.warning, "Could not decode guild")
        return
      }
      
      sword.guilds[guild.id] = guild
      
      if sword.unavailableGuilds.keys.contains(guild.id) {
        sword.unavailableGuilds.removeValue(forKey: guild.id)
        sword.on.guildAvailable(guild)
      } else {
        sword.on.guildCreate(guild)
      }
      
    // PRESENCE_UPDATE
    case .presenceUpdate:
      Sword.decoder.dateDecodingStrategy = .millisecondsSince1970
      guard let presence = decode(Presence.self, from: data) else {
        Sword.log(.warning, "Invalid presence structure received")
        return
      }
      
      sword.on.presenceUpdate(presence)
      
    // READY
    case .ready:
      guard let ready = decode(GatewayReady.self, from: data) else {
        Sword.log(.warning, "Unable to handle ready, disconnect")
        disconnect()
        return
      }
      
      // Make sure version we're connected to is the same as the version we requested
      guard ready.version == Sword.gatewayVersion else {
        Sword.log(.error, .invalidVersion(id))
        disconnect()
        return
      }
      
      sessionId = ready.sessionId
      sword.user = ready.user
      
      // Append unavailable guilds
      for ug in ready.unavailableGuilds {
        sword.unavailableGuilds[ug.id] = ug
      }
      
      addTrace(from: ready)
      
      sword.on.ready(ready.user)
      
    // RESUMED
    case .resumed:
      guard let resumed = decode(GatewayResumed.self, from: data) else {
        Sword.log(.warning, "Unable to retreive _trace from resumed, resuming anyways")
        return
      }
      
      addTrace(from: resumed)
      
      isReconnecting = false
      
    // TYPING_START
    case .typingStart:
      Sword.decoder.dateDecodingStrategy = .secondsSince1970
      guard let typing = decode(Typing.self, from: data) else {
        Sword.log(.warning, "Unable to handle TYPING_START")
        return
      }
      
      sword.on.typingStart(typing)
      
    default:
      break
    }
  }
}
