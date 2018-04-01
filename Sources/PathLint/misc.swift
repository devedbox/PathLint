//
//  misc.swift
//  PathLint
//
//  Created by devedbox on 2018/4/1.
//

import Foundation

public func checkPathRecursively(at path: String, founds: (String) -> Void) throws {
    let fileManager = FileManager.default
    var isDirectory: ObjCBool = false
    
    guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
        , isDirectory.boolValue else {
            
            founds(path)
        return
    }
    
    let contents = try fileManager.contentsOfDirectory(atPath: path)
    try contents.forEach { content in
        
        if  fileManager.fileExists(atPath: path.path(byAppending: content), isDirectory: &isDirectory),
            isDirectory.boolValue {
            
            // Then check again.
            try checkPathRecursively(at: path.path(byAppending: content), founds: founds)
        } else {
            // I think we have founds.
            founds(path.path(byAppending: content))
        }
    }
}
