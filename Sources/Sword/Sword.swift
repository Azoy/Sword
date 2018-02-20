//
//  Sword.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation
import Dispatch

/// Swift meets Discord
open class Sword {
  /// Used to encode stuff to send off to Discord
  static let encoder = JSONEncoder()
  
  /// Used to decode stuff from Discord
  static let decoder = JSONDecoder()
  
  /// Customizable options used when setting up the bot
  public var options: Options
  
  /// Used to block thread to complete url request
  let requestSema = DispatchSemaphore(value: 0)
  
  /// Shared URLSession
  let session = URLSession.shared
  
  /// Bot's Chuck E Cheese token to the magical world of Discord's API
  let token: String
  
  /// Instantiates a Sword instance
  ///
  /// - parameter token: The bot token used to connect to Discord's API
  /// - parameter options: Customizable options used when setting up the bot
  public init(token: String, options: Options = Options()) {
    self.options = options
    self.token = token
  }
  
  public func connect() {
    getGateway { info, error in
      guard let info = info else {
        return
      }
      
      print(info)
    }
  }
  
  public func getGateway(then: @escaping (GatewayInfo?, RequestError?) -> ()) {
    request(.gateway()) { data, error in
      guard let data = data else {
        then(nil, error)
        return
      }
      
      do {
        try then(Sword.decoder.decode(GatewayInfo.self, from: data), nil)
      } catch {
        then(nil, RequestError(error.localizedDescription))
      }
    }
  }
  
  /// Sends a message to a channel
  ///
  /// - parameter content: Message content to send to channel
  /// - parameter channelId: The channel ID to send this message to
  public func send(
    _ content: Message.Content,
    to channelId: String,
    then: ((Message?, Error?) -> ())? = nil
  ) {
    print("Get pranked")
  }
  
}
