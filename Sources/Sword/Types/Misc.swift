//
//  Misc.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation

extension Sword {
  /// Represents the info received from /gateway/bot
  public struct GatewayInfo: Decodable {
    /// The websocket url to connect the bot
    public let url: URL
    
    /// The number of recommended shards
    public let shards: UInt8
  }
}
