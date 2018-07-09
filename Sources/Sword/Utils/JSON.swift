//
//  JSON.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Used to grab data from message received from gateway
func decodePayload<T: Codable>(
  _ type: T.Type,
  from data: Data
) -> T? {
  do {
    let payload = try Sword.decoder.decode(PayloadData<T>.self, from: data)
    return payload.d
  } catch {
    Sword.log(.warning, error.localizedDescription)
    return nil
  }
}
