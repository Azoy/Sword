//
//  Bucket.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation
import Dispatch

/// Rate Limit Thing
class Bucket {

  // MARK: Properties

  /// Dispatch Queue to handle requests
  let worker: DispatchQueue

  /// Array of DispatchWorkItems to execute
  var queue = [DispatchWorkItem]()

  /// Limit on token count
  var limit: Int

  /// Interval at which tokens reset
  var interval: Int

  /// Current token count
  var tokens: Int

  /// Last reset in terms of Date
  var lastReset = Date()

  /// Used for Dispatch, but is basically ^
  var lastResetDispatch = DispatchTime.now()

  // MARK: Initializer

  /**
   Creates a bucket

   - parameter name: Name of bucket
   - parameter limit: Token limit
   - parameter interval: Interval at which tokens reset
   */
  init(name: String, limit: Int, interval: Int) {
    self.worker = DispatchQueue(label: name, qos: .userInitiated)
    self.limit = limit
    self.tokens = limit
    self.interval = interval
  }

  // MARK: Functions

  /// Check for token renewal and amount of tokens in bucket. If there are no more tokens then tell Dispatch to execute this function after deadline
  func check() {
    let now = Date()

    if now.timeIntervalSince(self.lastReset) > Double(self.interval) {
      self.tokens = self.limit
      self.lastReset = now
      self.lastResetDispatch = DispatchTime.now()
    }

    guard self.tokens > 0 else {
      self.worker.asyncAfter(
        deadline: self.lastResetDispatch + .seconds(self.interval + 1)
      ) {
        self.check()
      }

      return
    }

    self.execute()
  }

  /// Executes the first DispatchWorkItem in self.queue and removes a token from the bucket.
  func execute() {
    let item = self.queue.remove(at: 0)
    self.tokens -= 1
    self.worker.async(execute: item)
  }

  /**
   Queues the given item

   - parameter item: Code block to execute
   */
  func queue(_ item: DispatchWorkItem) {
    self.queue.append(item)
    self.check()
  }

  /**
   Used to take x amount of tokens from bucket (initial http request for route)

   - parameter num: Amount of tokens to take
   */
  func take(_ num: Int) {
    self.tokens -= num
  }

}
