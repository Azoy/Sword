//
//  Imageable.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

public protocol Imageable {
  /// Returns URL of this type
  func imageUrl(format: FileExtension) -> URL?
}
