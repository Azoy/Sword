//
//  OP.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

extension Sword {
  /// Represents a payload's opcode
  enum OP: Int, Codable {
    /// Opcode 0 (Discord event)
    case dispatch
    
    /// Opcode 1 (ping checks)
    case heartbeat
    
    /// Opcode 2 (handshake)
    case identify
    
    /// Opcode 3 (updates bot's status)
    case statusUpdate
    
    /// Opcode 4 (joins/moves/leaves a voice channel)
    case voiceStateUpdate
    
    /// Opcode 5 (voice ping checking)
    case voiceServerPing
    
    /// Opcode 6 (resumes a closed connection)
    case resume
    
    /// Opcode 7 (alerts bot to reconnect)
    case reconnect
    
    /// Opcode 8 (request guild members)
    case requestGuildMembers
    
    // Opcode 9 (invalid session id)
    case invalidSession
    
    /// Opcode 10 (heartbeat and server debug info once ready)
    case hello
    
    /// Opcode 11 (heartbeat acknowledgement)
    case ack
  }
}
