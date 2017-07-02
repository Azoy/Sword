//
//  Error.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

public struct RequestError: Error {
  
  public let code: Int
  
  public let error: [String: String]
  
  public let message: String
  
  public let statusCode: Int
  
  init(_ message: String) {
    self.code = 0
    self.error = [:]
    self.message = message
    self.statusCode = 0
  }
  
  init(_ statusCode: Int, _ response: Any) {
    self.statusCode = statusCode
    
    if let response = response as? [String: Any] {
      self.code = response["code"] as! Int
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
  
  init(_ error: NSError) {
    self.code = error.code
    self.error = [:]
    self.message = error.localizedDescription
    self.statusCode = 0
  }
  
  static func getSpecificError(for error: [String: Any], _ key: String = "") -> [String: String] {
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

enum VoiceError: Error {
  case encryptionFail, decryptionFail
}
