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
  public struct Error: Swift.Error {
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
    
    /// Creates a detailed description on why a request failed
    ///
    /// - parameter statusCode: HTTP status code of request
    /// - parameter response: Discord custom error response
    init(_ statusCode: Int, _ response: Any) {
      self.statusCode = statusCode
      
      if let response = response as? [String: Any] {
        self.code = response["code"] as? Int ?? 0
        self.message = response["message"] as! String
        
        if let error = response["errors"] as? [String: String] {
          self.error = error
        }else {
          self.error = [:]
        }
      } else {
        self.code = 0
        self.error = [:]
        self.message = response as! String
      }
    }
  }
}
