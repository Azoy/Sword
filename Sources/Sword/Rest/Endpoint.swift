//
//  Endpoint.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

import Foundation
import NIOHTTP1

/// Represents an API call
struct Endpoint {
  /// The http method used for this endpoint
  let method: HTTPMethod
  
  /// Path of endpoint
  let path: Path
  
  /// Query items
  var query = [URLQueryItem]()
  
  /// Bucket name for this endpoint
  var route: String {
    return "\(method):\(path.value):\(path.majorParam)"
  }
  
  /// The API URL
  var url: String {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "discordapp.com"
    components.path = "/api/" + Sword.apiVersion + path.value
    components.queryItems = query
    return components.url!.absoluteString
  }
  
  /// Creates an Endpoint
  ///
  /// - parameter method: The HTTP method used for this endpoint
  /// - parameter path: The API path for this endpoint
  init(_ method: HTTPMethod, _ path: Path) {
    self.method = method
    self.path = path
  }
}

extension Endpoint {
  // Nifty thing that allows us to do "/channels/\(major: id)/" and receive the
  // major param along with the whole url.
  struct Path: ExpressibleByStringInterpolation {
    let majorParam: String
    
    let value: String
    
    init(stringLiteral value: String) {
      self.value = value
      self.majorParam = ""
    }
    
    struct StringInterpolation: StringInterpolationProtocol {
      var output = ""
      
      var major = ""
      
      init(literalCapacity: Int, interpolationCount: Int) {}
      
      mutating func appendLiteral(_ literal: String) {
        output += literal
      }
      
      mutating func appendInterpolation(_ literal: String) {
        appendLiteral(literal)
      }
      
      mutating func appendInterpolation(major: String) {
        self.major = major
        appendLiteral(major)
      }
    }
    
    init(stringInterpolation: StringInterpolation) {
      self.value = stringInterpolation.output
      self.majorParam = stringInterpolation.major
    }
  }
}
