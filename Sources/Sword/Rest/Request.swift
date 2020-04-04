//
//  Request.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation
import AsyncHTTPClient
import NIO

extension Sword {
  static let apiVersion = "v7"
  
  static let version = "1.0.0"
}

extension Sword {
  func request<T: Decodable>(
    _ endpoint: Endpoint
  ) throws -> EventLoopFuture<T> {
    var request = try HTTPClient.Request(
      url: endpoint.url,
      method: endpoint.method
    )
    
    request.headers.add(
      name: "User-Agent",
      value: "DiscordBot (https://github.com/Azoy/Sword, \(Sword.version)"
    )
    
    request.headers.add(name: "Authorization", value: "Bot \(token)")
    
    let result = http.execute(request: request)
    
    result.whenFailure {
      Sword.log(.error, $0.localizedDescription)
    }
    
    return result.flatMapThrowing {
      let statusCode = $0.status.code
      
      // NO CONTENT
      if statusCode == 204 {
        throw Failure("")
      }
      
      let data = $0.body!.withUnsafeReadableBytes {
        Data(bytes: $0.baseAddress!, count: $0.count)
      }
      
      // Check status code for rate limit, permission issues, server problems...
      switch statusCode {
      case 200, // OK
           201, // CREATED
           304: // NOT MODIFIED
        break
      default:
        throw try Sword.decoder.decode(Failure.self, from: data)
      }
      
      // We can get the response data now
      return try Sword.decoder.decode(T.self, from: data)
    }
  }
}
