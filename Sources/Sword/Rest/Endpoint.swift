//
//  Endpoint.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Organizes different http methods
enum HTTPMethod: String {
  case delete, get, patch, post, put
}

/// Represents an API call
struct Endpoint {
  let majorParam: String
  
  /// The http method used for this endpoint
  let method: String
  
  /// Path of endpoint
  let path: String
  
  /// Query items
  var query = [URLQueryItem]()
  
  /// Bucket name for this endpoint
  var route: String {
    return "\(method):\(path):\(majorParam)"
  }
  
  /// The API URL
  var url: URL? {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "discordapp.com"
    components.path = "/api/" + Sword.apiVersion + path
    components.queryItems = query
    return components.url
  }
  
  /// Creates an Endpoint
  ///
  /// - parameter method: The HTTP method used for this endpoint
  /// - parameter url: The API URL for this endpoint
  init(_ method: HTTPMethod, _ path: String, _ majorParam: String = "") {
    self.majorParam = majorParam
    self.method = method.rawValue
    self.path = path
  }
}
