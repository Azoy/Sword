//
//  Error.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Custom Error type for quick details on why a request failed
public struct RequestError: Error {
  
  // MARK: Properties
  
  /// Discord custom error code
  public let code: Int
  
  /// More detailed message error in form of dictionary
  public let error: [String: String]
  
  /// Basic jist of why a request failed
  public let message: String
  
  /// HTTP status code on request
  public let statusCode: Int
  
  // MARK: Initializer
  
  /**
   Creates a basic error type with message
   
   - parameter message: Simple message on why request failed
  */
  init(_ message: String) {
    self.code = 0
    self.error = [:]
    self.message = message
    self.statusCode = 0
  }
  
  /**
   Creates a detailed description on why a request failed
   
   - parameter statusCode: HTTP status code of request
   - parameter response: Discord custom error response
  */
  init(_ statusCode: Int, _ response: Any) {
    self.statusCode = statusCode
    
    if let response = response as? [String: Any] {
      self.code = response["code"] as? Int ?? 0
      self.message = response["message"] as! String
      
      if let error = response["errors"] as? [String: Any] {
        self.error = RequestError.getSpecificError(for: error)
      }else {
        self.error = [:]
      }
    }else {
      self.code = 0
      self.error = [:]
      self.message = response as! String
    }
  }
  
  /**
   Creates a request error for client side request failures
   
   - parameter error: Error foundation reported
  */
  init(_ error: NSError) {
    self.code = error.code
    self.error = [:]
    self.message = error.localizedDescription
    self.statusCode = 0
  }
  
  /**
   Generates a specific error message from Discord's v7 error responses
   
   - parameter error: Error response
   - parameter key: Dictionary key
  */
  static func getSpecificError(
    for error: [String: Any],
    _ key: String = ""
  ) -> [String: String] {
    var items = [String: String]()
    
    for (k, v) in error {
      let newKey = key.isEmpty ? k : key + "." + k
      
      if let value = v as? [String: Any] {
        if let _errors = value["_errors"] as? [[String: String]] {
          for _error in _errors {
            if let errorMessage = _error["message"] {
              items[newKey] = errorMessage
            }else {
              items[newKey] = ""
            }
          }
        }else {
          items = RequestError.getSpecificError(for: value, newKey)
        }
      }else {
        items[newKey] = v as? String
      }
    }
    
    return items
  }
  
}

/// Simple enum error case for voice
enum VoiceError: Error {
  case encryptionFail, decryptionFail
}
