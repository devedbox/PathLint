//
//  misc.swift
//  PathLint
//
//  Created by devedbox on 2018/4/1.
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif
import Foundation

// MARK: - Public.

public func getcwd() -> String {
    return FileManager.default.currentDirectoryPath
}

public func asyncPrint<T>(_ t: T, on queue: DispatchQueue = DispatchQueue.main) { queue.async { print(t) } }
public func syncPrint<T>(_ t: T, on queue: DispatchQueue = DispatchQueue.main) { queue.sync { print(t) } }

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

public func lint(config: Configuration) throws -> [Violation] {
    return try lint(findPathsRecursively(using: config), using: config)
}

public func lint(_ paths: [String], using config: Configuration) throws -> [Violation] {
    defer {
        print("✅Lint Done!")
    }
    return try paths.flatMap { try lint(path: $0, using: config) }
}

public func lint(path: String, using config: Configuration) throws -> [Violation] {
    return try config.rules.flatMap { try $0.lint(path: path, config: config) }
}

public func execute(exit exitCode: Int32, throwing: () throws -> Void) {
    do {
        try throwing()
    } catch let error {
        print(error)
        exit(exitCode)
    }
}

// MARK: - Internal.

internal func _checkingFileExists(at path: String) -> (Bool, Bool) {
    var isDirectory: ObjCBool = false
    defer {
        isDirectory.boolValue ? asyncPrint("💔Empty contents at \(path).") : ()
    }
    guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
        asyncPrint("💔File does not exist at \(path).")
        return (exists: false, isDirectory: isDirectory.boolValue)
    }
    return (exists: true, isDirectory: isDirectory.boolValue)
}
