//
//  Enums.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2016 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Organize all dispatch events
enum OPCode: Int {

  case dispatch, heartbeat, identify, statusUpdate, voiceStateUpdate, voiceServerPing, resume, reconnect, requestGuildMember, invalidSession, hello, heartbeatACK

}

/// Organize all websocket close codes
enum CloseCode: Int {

  case unknownError = 4000, unknownOPCode, decodeError, notAuthenticated, authenticationFailed, alreadyAuthenticated, invalidSeq, rateLimited, sessionTimeout, invalidShard

}
