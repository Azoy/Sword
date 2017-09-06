//
//  Updatable.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Allows for a class to be updated at runtime
protocol Updatable: class {
  
  func update(_ json: [String: Any])
  
}
