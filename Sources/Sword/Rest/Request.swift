//
//  Request.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation

extension Sword {
  static let apiVersion = "v7"
  
  static let version = "1.0.0"
}

extension Sword {
  /// Makes an HTTP Request to the land of Discord's API
  ///
  /// - parameter endpoint: The specific endpoint to request
  func request(
    _ endpoint: Endpoint,
    then: @escaping (Sword, Data?, Sword.Error?) -> ()
  ) {
    /// Setup request
    var request = URLRequest(url: endpoint.url!)
    request.httpMethod = endpoint.method
    request.addValue(
      "DiscordBot (https://github.com/Azoy/Sword, \(Sword.version))",
      forHTTPHeaderField: "User-Agent"
    )
    
    /// Authorize this request with the bot's token
    request.addValue("Bot \(token)", forHTTPHeaderField: "Authorization")
    
    /// Setup data task
    let task = session.dataTask(with: request) {
      [unowned self] data, response, error in
      /// Handle any errors that happened during the request
      guard error == nil else {
        then(self, nil, Sword.Error(error!.localizedDescription))
        return
      }
      
      /// Handle the response first to do things like rate limiting
      guard let response = response as? HTTPURLResponse else {
        then(self, nil, Sword.Error("Unable to get a correct HTTP response."))
        return
      }
      
      self.handleRequestResponse(response, then)
      
      /// Make sure we can safely unwrap the data
      guard let data = data else {
        then(self, nil, Sword.Error("Unable to safely extract received data."))
        return
      }
      
      then(self, data, nil)
    }
    
    task.resume()
  }
  
  /// Handles what to do when a request is complete (rate limiting)
  ///
  /// - parameter response: The http response from the Discord
  func handleRequestResponse(
    _ response: HTTPURLResponse,
    _ then: @escaping (Sword, Data?, Sword.Error?) -> ()) {
    Sword.log(.warning, "Get pranked")
  }
}
