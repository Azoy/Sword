//
//  Log.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

extension Sword {

  /**
   Logs the given message

   - parameter message: Info to output
  */
  func log(_ message: String) {
    guard self.options.willLog else {
      return
    }

    print("[Sword] " + message)
  }

  /**
   Logs the given warning message

   - parameter message: Warning to output
  */
  func warn(_ message: String) {
    let prefix = "\u{001B}[1;93mWarning: \u{001B}[0m"
    self.log(prefix + message)
  }

  /**
   Logs the given error message

   - parameter message: Error to output
  */
  func error(_ message: String) {
    let prefix = "\u{001B}[1;91mError: \u{001B}[0m"
    self.log(prefix + message)
  }

}
