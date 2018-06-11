//
//  Diagnostics.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

enum Diagnostic {
  case dispatchJSON
  case dispatchName(UInt8)
  case gatewayConnectFailure(String)
  case invalidURL(String)
  case invalidVersion(UInt8)
  case missing(UInt8, String, String?)
  case unhandledEvent(UInt8, Int)
  case unknownEvent(String)
}

extension Diagnostic {
  func getMsg() -> String {
    switch self {
    case .dispatchJSON:
      return "Was expecting a JSON object while handling dispatch event"
      
    case let .dispatchName(shardId):
      return "Shard \(shardId) received dispatch payload without event name"
      
    case let .gatewayConnectFailure(reason):
      return "Unable to connect to gateway: \(reason)"
      
    case let .invalidURL(url):
      return "Unable to form a proper url to connect gateway handler: \(url)"
      
    case let .invalidVersion(shardId):
      return "Shard \(shardId) connected to wrong version of the gateway"
      
    case let .missing(shardId, key, eventName):
      guard let eventName = eventName else {
        return "Shard \(shardId) did not receive \(key)"
      }
      
      return "Shard \(shardId) did not receive \(key) during \(eventName)"
      
    case let .unhandledEvent(shardId, opCode):
      return "Shard \(shardId) received unhandled payload event: \(opCode)"
      
    case let .unknownEvent(eventName):
      return "Received unknown dispatch event: \(eventName)"
    }
  }
}
