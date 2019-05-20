//
//  Interface.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

import NIO

extension Sword {
  /// Get's the bot's initial gateway information for the websocket
  public func getGateway() throws -> EventLoopFuture<GatewayInfo> {
    return try request(.gateway)
  }
}
