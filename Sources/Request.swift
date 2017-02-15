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

    request.addValue("DiscordBot (https://github.com/Azoy/Sword, 0.4.0)", forHTTPHeaderField: "User-Agent")

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
          self.handleRateLimited(with: headers, and: sema)
        }

        if response.statusCode >= 500 {
          self.globalQueue.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
            self.request(url, body: body, file: file, authorization: authorization, method: method, rateLimited: rateLimited, completion: completion)
          }

          sema.signal()
          return
        }

        completion(response.status, nil)
        sema.signal()
        return
      }

      if rateLimited {
        self.handle(rateLimitHeaders: headers, with: route)
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
