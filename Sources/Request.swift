//
//  Request.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2016 Alejandro Alonso. All rights reserved.
//

import Foundation
import Dispatch

/// HTTP Handler
class Request {

  // MARK: Properties

  /// The bot token
  let token: String

  /// Global URLSession (trust me i saw it on a wwdc talk, this is legit lmfao)
  let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue())

  /// Collection of Collections of buckets mapped by method mapped by route
  var rateLimits: [String: [String: Bucket]] = [:]

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
    guard let result = regex.firstMatch(in: url, options: [], range: NSMakeRange(0, string.length)) else {
      return ""
    }

    return string.substring(with: result.range)
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
  func request(_ url: String, body: Data? = nil, file: [String: Any]? = nil, authorization: Bool = true, method: String = "GET", rateLimited: Bool = true, completion: @escaping (Error?, Any?) -> ()) {
    let sema = DispatchSemaphore(value: 0) //Provide a way to urlsession from command line

    let route = rateLimited ? self.getRoute(for: url) : ""

    let realUrl = "https://discordapp.com/api\(url)"

    var request = URLRequest(url: URL(string: realUrl)!)
    request.httpMethod = method

    if authorization {
      request.addValue("Bot \(token)", forHTTPHeaderField: "Authorization")
    }

    request.addValue("DiscordBot (https://github.com/Azoy/Sword, 0.1.0)", forHTTPHeaderField: "User-Agent")

    if file != nil {
      #if !os(Linux)
      let boundary = generateBoundaryString()
      let path = file!["file"] as! String

      request.httpBody = try? createBody(with: file!["parameters"] as? [String: String], fileKey: "file", paths: [path], boundary: boundary)
      request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
      #else
      request.httpBody = (file!["parameters"] as? [String: String]).encode()
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
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
          sleep(5)
        }

        if response.statusCode >= 500 {
          sleep(3)
        }

        completion(response.status, nil)
        sema.signal()
        return
      }

      if rateLimited && route != "" && self.rateLimits[route]?[method] == nil {

        #if !os(Linux)
        let limit = Int(headers["x-ratelimit-limit"] as! String)!
        let interval = Int(Double(headers["x-ratelimit-reset"] as! String)! - (headers["Date"] as! String).dateNorm.timeIntervalSince1970)
        #else
        let limit = Int(headers["X-RateLimit-Limit"]!)!
        let interval = Int(Double(headers["X-RateLimit-Reset"]!)! - (headers["Date"] as! String).dateNorm.timeIntervalSince1970)
        #endif

        let bucket = Bucket(name: "gg.azoy.sword.\(route).\(method)", limit: limit, interval: interval)
        bucket.take(1)

        if self.rateLimits[route] == nil {
          self.rateLimits[route] = [method: bucket]
        }else {
          self.rateLimits[route]![method] = bucket
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

    if rateLimited && self.rateLimits[route] != nil && self.rateLimits[route]?[method] != nil {
      let item = DispatchWorkItem {
        task.resume()

        sema.wait()
      }
      self.rateLimits[route]![method]!.queue(item)
    }else {
      task.resume()

      sema.wait()
    }

  }

}
