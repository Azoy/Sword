import Foundation

extension Date {

  var milliseconds: Int {
    return Int((self.timeIntervalSince1970 * 1000.0).rounded())
  }

}
