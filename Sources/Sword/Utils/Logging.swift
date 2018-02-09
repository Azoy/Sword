//
//  Logging.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

extension Sword {
  struct Logger {
    /// Whether or not logging is enabled
    static var isEnabled = false
    
    /// Different forms of a logged message
    #if !os(Linux)
    enum LogType: String {
      case info    = "Info:"
      case warning = "\u{001B}[1;93mWarning: \u{001B}[0m"
      case error   = "\u{001B}[1;91mError: \u{001B}[0m"
    }
    #else
    enum LogType: String {
      case info    = "Info:"
      case warning = "\\e[38;1;93mWarning: \\e[0m"
      case error   = "\\e[38;1;31mError: \\e[0m"
    }
    #endif
  }
  
  /// Logs a message if logging is enabled
  ///
  /// - parameter type: Kind of msg
  /// - parameter msg: Message to log out
  static func log(_ type: Logger.LogType, _ msg: String) {
    guard Logger.isEnabled else {
      return
    }
    
    print(type.rawValue + msg)
  }
}
