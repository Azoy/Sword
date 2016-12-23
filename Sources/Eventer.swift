import Foundation

//Create a nifty Event Emitter in Swift
open class Eventer {

  var listeners: [String: [(Any) -> ()]] = [:]

  /* Function thats called when the same eventName is emitted
    @param eventName: String - Name of the event to listen for
  */
  open func on(_ eventName: String, _ completion: @escaping (Any) -> ()) {
    guard self.listeners[eventName] != nil else {
      self.listeners[eventName] = [completion]
      return
    }
    self.listeners[eventName]!.append(completion)
  }

  /* Function that emits all listens with the same eventName
    @param eventName: String - Name of event to emit
    @param data: [Any] - Array of variables the listener is expecting to receive
  */
  open func emit(_ eventName: String, with data: [Any]) {
    guard let functions = self.listeners[eventName] else { return }
    for function in functions {
      function(data)
    }
  }

}
