//
//  misc.swift
//  PathLint
//
//  Created by devedbox on 2018/4/1.
//

import Foundation

public func getcwd() -> String {
    return FileManager.default.currentDirectoryPath
}

public func findPathsRecursively(at path: String = getcwd(), using config: Configuration) throws -> [String] {
    guard config.excludes.filter({ path.hasSuffix($0) }).isEmpty else {
        return []
    }
    
    var paths: [String] = []
    
    let fileManager = FileManager.default
    var isDirectory: ObjCBool = false
    
    guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
        , isDirectory.boolValue else {
            
        paths.append(path)
        return paths
    }
    
    let contents = try fileManager.contentsOfDirectory(atPath: path)
    try contents.forEach { content in
        
        if  fileManager.fileExists(atPath: path.path(byAppending: content), isDirectory: &isDirectory),
            isDirectory.boolValue {
            
            // Then find again.
            paths.append(contentsOf: try findPathsRecursively(at: path.path(byAppending: content), using: config))
        } else {
            // I think we have founds.
            if config.excludes.filter({ content.hasSuffix($0) }).isEmpty {
                paths.append(path.path(byAppending: content))
            }
        }
    }
    
    return paths
}

public func lint(path: String, using config: Configuration) throws -> [Violation] {
    defer {
        print("✅Lint Done!")
    }
    return try config.rules.flatMap { try $0.lint(path: path, excludes: config.excludes) }
}
