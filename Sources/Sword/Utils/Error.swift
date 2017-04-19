//
//  Error.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Organize all possible status responses from api
public enum RequestError {

  /// 304 - Entity was not modifed
  case notModified

  /// 400 - Improper formatting, or server couldn't figure it out
  case badRequest

  /// 401 - Auth header missing or invalid
  case unauthorized

  /// 403 - Auth token does not have permission for resource
  case forbidden

  /// 404 - Resource was not found at location
  case notFound

  /// 405 - HTTP method used is not valid for location
  case methodNotAllowed

  /// 429 - RATE LIMITEDDD (most likely global, but maybe have made a hiccup)
  case tooManyRequests

  /// 502 - Gateway did not process request. Try again.
  case gatewayUnavailable

  /// 5xx - Server errors
  case serverError

  /// Most likely a json error if any
  case unknown

}


extension HTTPURLResponse {

  /// Create computed variable to get Error enum from statusCode
  var status: RequestError {

    switch self.statusCode {
      case 304:
        return .notModified
      case 400:
        return .badRequest
      case 401:
        return .unauthorized
      case 403:
        return .forbidden
      case 404:
        return .notFound
      case 405:
        return .methodNotAllowed
      case 429:
        return .tooManyRequests
      case 502:
        return .gatewayUnavailable
      case 500 ... 599:
        return .serverError
      default:
        return .unknown
    }

  }

}

enum VoiceError: Error {
  case encryptionFail, decryptionFail
}
