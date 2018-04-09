//
//  PathRule.swift
//  pathlint
//
//  Created by devedbox on 2018/4/1.
//

import Foundation

public struct PathRule: RuleProtocol, Decodable {
    enum CodingKeys: String, CodingKey {
        case path
        case pattern
        case severity
        case isRelativedToBasePattern = "relative_to_base"
        case ignores
    }
    
    public let path: String // The file directory end node: Models/
    public var pattern: String // The pattern to lint the file name: [a-zA-Z0-9_-+]Model.swift
    
    public var severity: ReportSeverity
    public let isRelativedToBasePattern: Bool?
    
    public let ignores: [String]
}

extension PathRule {
    /// Lint the given path with the rule
    public func lint(path: String,
                     config: Configuration,
                     hit: ((Violation) -> Void)? = { print($0) }) throws -> [Violation] {
        
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
            !config.excludes.contains(String(dir))
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
        let finalPattern = isRelativedToBasePattern ?? true ? config.basePattern + pattern : pattern
        
        if !NSPredicate(format: "SELF MATCHES[cd] \"\(finalPattern)\"").evaluate(with: fileName) {
            let violation = Violation(file: path,
                                      severity: severity,
                                      reason: "File Path Violation: File name `\(fileName)` should followd by pattern: \(finalPattern)")
            hit?(violation)
            violations.append(violation)
        }
        return violations
    }
}