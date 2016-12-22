import Foundation
import Dispatch

class Bucket {

  let worker: DispatchQueue
  var queue: [DispatchWorkItem] = []

  let limit: Int
  let interval: Int
  var tokens: Int
  var lastReset = Date()
  var lastResetDispatch = DispatchTime.now()

  init(name: String, limit: Int, interval: Int) {
    self.worker = DispatchQueue(label: name, qos: .userInitiated)
    self.limit = limit
    self.tokens = limit
    self.interval = interval
  }

  func queue(_ item: DispatchWorkItem) {
    self.queue.append(item)
    self.check()
  }

  func take(_ num: Int) {
    self.tokens -= 1
  }

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

  func execute() {
    let item = self.queue.remove(at: 0)
    self.tokens -= 1
    self.worker.async(execute: item)
  }

}
