import Foundation

open class Eventer {
  var listeners: [String: [(Any) -> Void]] = [:]

  open func on(_ eventName: String, _ completion: @escaping (_ data: Any) -> Void) {
    guard self.listeners[eventName] != nil else {
      self.listeners[eventName] = [completion]
      return
    }
    self.listeners[eventName]!.append(completion)
  }

  open func emit(_ eventName: String, with data: [Any]) {
    guard let functions = self.listeners[eventName] else { return }
    for function in functions {
      function(data)
    }
  }
}
