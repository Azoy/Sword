//
//  Request.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation
import Dispatch

/// HTTP Handler
class Request {

  // MARK: Properties

  /// Used to store requests when being globally rate limited
  var globalLockQueue: [() -> ()] = []

  /// Whether or not the global queue is locked
  var globallyLocked = false

  /// The queue that handles requests made after being globally limited
  let globalQueue = DispatchQueue(label: "gg.azoy.sword.global")

  /// Collection of Collections of buckets mapped by route
  var rateLimits: [String: Bucket] = [:]

  /// Global URLSession (trust me i saw it on a wwdc talk, this is legit lmfao)
  let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue())

  /// The bot token
  let token: String

  // MARK: Initializer

  /**
   Creates Request Class

   - parameter token: Bot token to use for Authorization
  */
  init(_ token: String) {
    self.token = token
  }

  /**
   Gets the "route" for an HTTP request

   - parameter url: URL to get route from
  */
  func getRoute(for url: String) -> String {

    #if !os(Linux)
    let regex = try! NSRegularExpression(pattern: "/([a-z-]+)/(?:[0-9]{17,})+?", options: .caseInsensitive)
    #else
    let regex = try! RegularExpression(pattern: "/([a-z-]+)/(?:[0-9]{17,})+?", options: .caseInsensitive)
    #endif

    let string = NSString(string: url)
    let matches = regex.matches(in: url, options: [], range: NSMakeRange(0, string.length))
    var returnRoute = ""

    for match in matches {
      var parameters = string.substring(with: match.range).components(separatedBy: "/")
      if parameters[1] == "channels" || parameters[1] == "guilds" {
        returnRoute += parameters.joined(separator: "/")

        continue
      }
      parameters.remove(at: 2)

      returnRoute += parameters.joined(separator: "/")
    }

    let parameters = url.components(separatedBy: "/")
    if parameters.count % 2 == 0 {
      returnRoute += "/" + parameters[parameters.count - 1]
    }

    return returnRoute
  }

  func globalUnlock() {
    self.globallyLocked = false
    for request in self.globalLockQueue {
      request()
    }
  }

  /**
   Actual HTTP Request

   - parameter url: URL to request
   - parameter body: Optional Data to send to server
   - parameter file: Optional for when files
   - parameter authorization: Whether or not the Authorization header is required by Discord
   - parameter method: Type of HTTP Method
   - parameter rateLimited: Whether or not the HTTP request needs to be rate limited
  */
  func request(_ url: String, body: Data? = nil, file: [String: Any]? = nil, authorization: Bool = true, method: String = "GET", rateLimited: Bool = true, completion: @escaping (RequestError?, Any?) -> ()) {
    let sema = DispatchSemaphore(value: 0) //Provide a way to urlsession from command line

    let route = rateLimited ? self.getRoute(for: url) : ""

    let realUrl = "https://discordapp.com/api\(url)"

    var request = URLRequest(url: URL(string: realUrl)!)
    request.httpMethod = method

    if authorization {
      request.addValue("Bot \(token)", forHTTPHeaderField: "Authorization")
    }

    request.addValue("DiscordBot (https://github.com/Azoy/Sword, 0.3.0)", forHTTPHeaderField: "User-Agent")

    if file != nil {
      #if !os(Linux)
      let boundary = generateBoundaryString()
      let path = file!["file"] as! String

      request.httpBody = try? createBody(with: file!["parameters"] as? [String: String], fileKey: "file", paths: [path], boundary: boundary)
      request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
      #else
      if file!["parameters"] != nil {
        request.httpBody = (file!["parameters"] as! [String: String]).encode().data(using: .utf8)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      }
      #endif
    }else if body != nil {
      request.httpBody = body
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    let task = self.session.dataTask(with: request) { data, response, error in
      let response = response as! HTTPURLResponse
      let headers = response.allHeaderFields

      if error != nil {
        completion(.unknown, nil)
        sema.signal()
        return
      }

      if response.statusCode == 204 {
        completion(nil, nil)
        sema.signal()
        return
      }

      if response.statusCode != 200 && response.statusCode != 201 {

        if response.statusCode == 429 {
          #if !os(Linux)
          let retryAfter = Int(headers["retry-after"] as! String)!
          let global = headers["x-ratelimit-global"]
          #else
          let retryAfter = Int(headers["Retry-After"]!)!
          let global = headers["X-RateLimit-Global"]
          #endif

          guard global == nil else {
            self.globalQueue.asyncAfter(deadline: DispatchTime.now() + .seconds(retryAfter)) {
              self.globalUnlock()
            }

            return
          }
        }

        if response.statusCode >= 500 {
          sleep(3)
        }

        completion(response.status, nil)
        sema.signal()
        return
      }

      if rateLimited {
        #if !os(Linux)
        let limitHeader = headers["x-ratelimit-limit"]
        let remainingHeader = headers["x-ratelimit-remaining"]
        let intervalHeader = headers["x-ratelimit-reset"]
        #else
        let limitHeader = headers["X-RateLimit-Limit"]
        let remainingHeader = headers["X-RateLimit-Remaining"]
        let intervalHeader = headers["X-RateLimit-Reset"]
        #endif

        if limitHeader != nil && remainingHeader != nil && intervalHeader != nil {
          #if !os(Linux)
          let limit = Int(limitHeader as! String)!
          let remaining = Int(remainingHeader as! String)!
          let interval = Int(Double(intervalHeader as! String)! - (headers["Date"] as! String).dateNorm.timeIntervalSince1970)
          #else
          let limit = Int(limitHeader!)!
          let remaining = Int(remainingHeader!)!
          let interval = Int(Double(intervalHeader!)! - (headers["Date"]!).dateNorm.timeIntervalSince1970)
          #endif

          if route != "" && self.rateLimits[route] == nil {
            let bucket = Bucket(name: "gg.azoy.sword.\(route)", limit: limit, interval: interval)
            bucket.take(1)

            self.rateLimits[route] = bucket
          }else {
            if self.rateLimits[route]!.tokens != remaining {
              self.rateLimits[route]!.tokens = remaining
            }

            if self.rateLimits[route]!.limit != limit {
              self.rateLimits[route]!.limit = limit
            }
          }
        }else {
          if route != "" && self.rateLimits[route] == nil {
            let bucket = Bucket(name: "gg.azoy.sword.\(route)", limit: 1, interval: 2)
            bucket.take(1)

            self.rateLimits[route] = bucket
          }
        }
      }

      do {
        let returnedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        completion(nil, returnedData)
      }catch {
        completion(.unknown, nil)
      }

      sema.signal()
    }

    let apiCall = {
      if rateLimited && self.rateLimits[route] != nil {
        let item = DispatchWorkItem {
          task.resume()

          sema.wait()
        }
        self.rateLimits[route]!.queue(item)
      }else {
        task.resume()

        sema.wait()
      }
    }

    if !self.globallyLocked {
      apiCall()
    }else {
      self.globalLockQueue.append(apiCall)
    }

  }

}
