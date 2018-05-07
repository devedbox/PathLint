//
//  PathRule.swift
//  pathlint
//
//  Created by devedbox on 2018/4/1.
//

import Foundation

// MARK: - PathRule.

/// A type represents the rule to check verifying the path of any given specific file. A path rule
/// can also contain several content rules to find and check the content of the given file.
public struct PathRule: Decodable {
    /// The coding keys of `PathRule`.
    internal enum CodingKeys: String, CodingKey {
        /// Coding key for `path`.
        case path
        /// Coding key for `pattern`.
        case pattern
        /// Coding key for `severity`.
        case severity
        /// Coding key for `relative_to_base`.
        case isRelativedToBasePattern = "relative_to_base"
        /// Coding key for `ignores.`
        case ignores
        /// Coding key for `content_rules`.
        case contentRules = "content_rules"
    }
    /// Path suffix to check with the pattern.
    public let path: String // The file directory end node: Models/
    /// Rule pattern to validate the path.
    public var pattern: String // The pattern to lint the file name: [a-zA-Z0-9_-+]Model.swift
    /// Value of `ReportSeverity` indicates the warning or error.
    public var severity: ReportSeverity
    /// Should treat the pattern as trailing of the base pattern.
    public let isRelativedToBasePattern: Bool?
    /// The ignores list using a complete matching.
    public let ignores: [String]
    /// Rules to lint with the content of the file.
    public let contentRules: [FileContentsRule]?
}

// MARK: - RuleProtocol.

extension PathRule: RuleProtocol {
    /// Lint the given path with the rule pattern if the path matchs the path of the rule.
    ///
    /// - Parameter path: The path to be validated.
    /// - Parameter config: The configuration of the lint target.
    /// - Parameter hit: Closure to be triggered when matching results.
    ///
    /// - Returns: Violations of the given path and all subpaths.
    public func lint(path: String,
                     config: Configuration,
                     hit: ((Violation) -> Void)? = { print($0) }) throws -> [Violation] {
        // Pre condition.
        guard try _checkingFileExists(at: path) == (true, false) else { return [] }
        // Get the file name.
        var components = path.split(separator: "/")
        let fileName = components.removeLast()
        // Excluding the path if any.
        guard
            let dir = components.last,
            !config.excludes.contains(String(dir))
        else {
            print("💔Excluding path: \(path).")
            return []
        }
        // Make sure the path is on the given dir of the rule.
        guard NSPredicate(format: "SELF MATCHES[cd] \"\(dir)[/]*\"").evaluate(with: self.path) else {
            return []
        }
        // Logging.
        print("Linting \(path)")
        // Ignoring file name.
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
        return
            violations
            + (try ((contentRules ?? []) + (config.globalContentRules ?? []))
                .flatMap { try $0.lint(path: path, config: config, hit: hit) } )
    }
}
