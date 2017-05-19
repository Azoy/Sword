//
//  Youtube.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

#if !os(iOS)

import Foundation

/// Creates a Youtube structure to play audio from (Requires youtube-dl to be installed)
public struct Youtube {

  // MARK: Properties

  /// The process controlling youtube-dl
  public var process: Process

  /**
   Creates a Youtube Structure

   - parameter link: The youtube-dl link to get audio from
   - parameter arguments: Extra arguments that you want to include in youtube-dl runtime
  */
  public init(_ link: String, with arguments: [String] = []) {
    self.process = Process()
    self.process.launchPath = "/usr/local/bin/youtube-dl"
    self.process.arguments = ["-f", "bestaudio", "-q", "-o", "-", link]
    self.process.arguments! += arguments
  }

}

#endif
