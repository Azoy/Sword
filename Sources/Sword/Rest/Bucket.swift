//
//  Bucket.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//
/*
import Foundation
import Dispatch

/// Rate Limit Thing
class Bucket {
  /// Dispatch Queue to handle requests
  let worker: DispatchQueue
  
  /// Array of DispatchWorkItems to execute
  var queue = [() -> ()]()
  
  /// Limit on token count
  var limit: Int
  
  /// Token reset
  var reset: Int
  
  /// Current token count
  var tokens: Int
  
  /// Last reset in terms of Date
  var lastReset = Date()
  
  /// Used for Dispatch, but is basically ^
  var lastResetDispatch = DispatchTime.now()
  
  /// Creates a bucket
  /// - parameter name: Name of bucket
  /// - parameter limit: Token limit
  /// - parameter interval: Interval at which tokens reset
  init(name: String, limit: Int, reset: Int) {
    self.worker = DispatchQueue(label: name, qos: .userInitiated)
    self.limit = limit
    self.tokens = limit - 1
    self.reset = reset
  }
  
  /// Check for token renewal and amount of tokens in bucket.
  /// If there are no more tokens then tell Dispatch to execute this function
  /// after deadline.
  func check() {
    let now = Date()
    
    if now.timeIntervalSince1970 > Double(reset) {
      tokens = limit
      lastReset = now
      lastResetDispatch = .now()
    }
    
    guard tokens > 0 else {
      let interval: DispatchTimeInterval = .seconds(Double(reset) -
                                           lastReset.timeIntervalSince1970)
      worker.asyncAfter(
        deadline: lastResetDispatch + DispatchTimeInterval.seconds(Double(reset) - lastReset.timeIntervalSince1970)
      ) { [unowned self] in
        self.check()
      }
      
      return
    }
    
    execute()
  }
  
  /// Executes the first DispatchWorkItem in self.queue and removes
  /// a token from the bucket.
  func execute() {
    let item = queue.removeFirst()
    tokens -= 1
    worker.async(execute: item)
  }
  
  /// Queues the given item
  ///
  /// - parameter item: Code block to execute
  func queue(_ item: @escaping () -> ()) {
    queue.append(item)
    check()
  }
}
*/
