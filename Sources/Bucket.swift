import Foundation
import Dispatch

//Rate Limit Thing
class Bucket {

  let worker: DispatchQueue
  var queue: [DispatchWorkItem] = []

  let limit: Int
  let interval: Int
  var tokens: Int
  var lastReset = Date()
  var lastResetDispatch = DispatchTime.now()

  /* Creates the Bucket
    @param name: String - The name for the dispatch queue
    @param limit: Int - The limit of tokens in the bucket
    @param interval - The interval at which tokens in the bucket reset
  */
  init(name: String, limit: Int, interval: Int) {
    self.worker = DispatchQueue(label: name, qos: .userInitiated)
    self.limit = limit
    self.tokens = limit
    self.interval = interval
  }

  /* Queues the code block
    @param item: DispatchWorkItem - Code block request
  */
  func queue(_ item: DispatchWorkItem) {
    self.queue.append(item)
    self.check()
  }

  /* Used for instances where bucket is generated from header codes to remove a call from the bucket.
    @param num: Int - Number of tokens to take from the bucket
  */
  func take(_ num: Int) {
    self.tokens -= 1
  }

  // Check for token renewal and amount of tokens in bucket. If there are no more tokens then tell Dispatch to execute this function after deadline
  func check() {
    let now = Date()

    if now.timeIntervalSince(self.lastReset) > Double(self.interval) {
      self.tokens = self.limit
      self.lastReset = now
      self.lastResetDispatch = DispatchTime.now()
    }

    if self.tokens == 0 {
      self.worker.asyncAfter(deadline: self.lastResetDispatch + .seconds(self.interval)) {
        self.check()
      }

      return
    }

    self.execute()
  }

  //Executes the first DispatchWorkItem in self.queue and removes a token from the bucket.
  func execute() {
    let item = self.queue.remove(at: 0)
    self.tokens -= 1
    self.worker.async(execute: item)
  }

}
