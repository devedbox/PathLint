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
    let fileManager = FileManager.default
    var isDirectory: ObjCBool = false
    
    guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else {
        print("💔File does not exist at \(path).")
        return []
    }
    guard !isDirectory.boolValue else {
        return []
    }
    
    var components = path.split(separator: "/")
    let fileName = components.removeLast()
    guard let dir = components.last
        , !config.excludes.contains(String(dir)) else {
        print("💔Excluding path: \(path).")
        return []
    }
    
    return
        config.rules
    .filter  { NSPredicate(format: "SELF MATCHES[cd] \"\(dir)[/]*\"").evaluate(with: $0.path) }
    .flatMap { ele -> [Violation] in
        print("Linting \(path)")
        guard !ele.ignores.contains(String(fileName)) else {
            print("Ignoring \(fileName)")
            return []
        }
        
        var violations: [Violation] = []
        if String(fileName[fileName.startIndex]).isUppercase() != ele.uppercasePrefix {
            let violation = Violation(file: path,
                                      severity: ele.severity,
                                      reason: "File Path Violation: File name `\(fileName)` should \(ele.uppercasePrefix ? "" : "not") be uppercase")
            print(violation)
            violations.append(violation)
        }
        if !NSPredicate(format: "SELF MATCHES[cd] \"\(ele.pattern)\"").evaluate(with: fileName) {
            let violation = Violation(file: path,
                                      severity: ele.severity,
                                      reason: "File Path Violation: File name `\(fileName)` should followd by pattern: \(ele.pattern)")
            print(violation)
            violations.append(violation)
        }
        return violations
    }
}
