//
//  Mutex.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

#if !os(Linux)
import Darwin
#else
import Glibc
#endif

class Mutex {
  var mutex = pthread_mutex_t()
  
  init() {
    var attr = pthread_mutexattr_t()
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL)
    
    guard pthread_mutex_init(&mutex, &attr) == 0 else {
      fatalError("Unable to instantiate mutex")
    }
    
    pthread_mutexattr_destroy(&attr)
  }
  
  deinit {
    pthread_mutex_destroy(&mutex)
  }
  
  func lock() {
    pthread_mutex_lock(&mutex)
  }
  
  func unlock() {
    pthread_mutex_unlock(&mutex)
  }
}

let _mutex = Mutex()

func locked(do function: () -> ()) {
  _mutex.lock()
  defer { _mutex.unlock() }
  function()
}
