//
//  Rule.swift
//  pathlint
//
//  Created by devedbox on 2018/4/1.
//

import Foundation

public struct Rule: Decodable {
    public enum Severity: String, Decodable {
        case warning
        case error
    }
    
    let path: String // The file directory end node: Models/
    let pattern: String // The pattern to lint the file name: [a-zA-Z0-9_-+]Model.swift
    
    let severity: Severity
    
    let ignores: [String]
}

extension Rule {
    /// Lint the given path with the rule
    public func lint(path: String, excludes: [String], hit: ((Violation) -> Void)? = { print($0) }) throws -> [Violation] {
        var isDirectory: ObjCBool = false
        
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
            print("💔File does not exist at \(path).")
            return []
        }
        guard !isDirectory.boolValue else {
            print("💔Empty contents at \(path).")
            return []
        }
        
        var components = path.split(separator: "/")
        let fileName = components.removeLast()
        
        guard
            let dir = components.last,
            !excludes.contains(String(dir))
        else {
                print("💔Excluding path: \(path).")
                return []
        }
        
        guard NSPredicate(format: "SELF MATCHES[cd] \"\(dir)[/]*\"").evaluate(with: self.path) else {
            return []
        }
        
        print("Linting \(path)")
        
        guard !ignores.contains(String(fileName)) else {
            print("Ignoring \(fileName)")
            return []
        }
        
        var violations: [Violation] = []
        
        if !NSPredicate(format: "SELF MATCHES[cd] \"\(pattern)\"").evaluate(with: fileName) {
            let violation = Violation(file: path,
                                      severity: severity,
                                      reason: "File Path Violation: File name `\(fileName)` should followd by pattern: \(pattern)")
            hit?(violation)
            violations.append(violation)
        }
        return violations
    }
}
