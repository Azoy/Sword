//
//  Error.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation

extension Sword {
  /// Custom Error type for quick details on why a request failed
  public struct Failure: Error, Decodable {
    /// Discord custom error code
    public let code: Int
    
    /// More detailed message error in form of dictionary
    public let error: [String: String]
    
    /// Basic jist of why a request failed
    public let message: String
    
    /// HTTP status code on request
    public let statusCode: Int
    
    /// Creates a basic error type with message
    ///
    /// - parameter message: Simple message on why request failed
    init(_ message: String) {
      self.code = 0
      self.error = [:]
      self.message = message
      self.statusCode = 0
    }
  }
}
