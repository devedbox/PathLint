//
//  FileManager.Nodes.swift
//  PathLintFramework
//
//  Created by devedbox on 2018/9/18.
//

import Foundation

// MARK: - Nodes.

internal extension FileManager {
  internal func nodes(
    in path: String,
    filter: (String) throws -> Bool) throws -> [String]
  {
    var isDirectory: ObjCBool = false
    
    guard fileExists(atPath: path, isDirectory: &isDirectory) else {
      return []
    }
    
    guard try filter(path) else {
      return []
    }
    
    guard isDirectory.boolValue else {
      return [path]
    }
    
    return try contentsOfDirectory(atPath: path).flatMap {
      return try nodes(
        in: path.path(byAppending: $0),
        filter: filter
      )
    }
  }
}
