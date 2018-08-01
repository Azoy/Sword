//
//  QoL.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

typealias Bytes = [UInt8]

// 64kb
let maxBufSize = 0x10000

extension UnsafeMutableBufferPointer {
  mutating func realloc(size: Int) {
    let newBuffer = UnsafeMutableBufferPointer<Element>.allocate(
      capacity: size
    )
    
    // Copy original data into new buffer
    for index in indices {
      newBuffer[index] = self[index]
    }
    
    // Deallocate the original buffer
    deallocate()
    
    self = newBuffer
  }
}
