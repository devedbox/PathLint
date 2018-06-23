//
//  FileContentsRule.swift
//  PathLintFramework
//
//  Created by devedbox on 2018/4/9.
//

import Foundation

// MARK: - FileContentsRuleError.

/// Error type represents the error info of file contents rule domain.
public enum FileContentsRuleError: CustomStringConvertible, Error {
    /// Invalid contents of the given path.
    case invalidContents(path: String)
    /// Returns the description of the error.
    public var description: String {
        switch self {
        case .invalidContents(path: let path):
            return "The contents at '\(path)' is invalid."
        }
    }
}

// MARK: - FileContentsRule.

/// A type represents the rule of the contents of a given path.
public struct FileContentsRule: Decodable {
    /// The violation fixing pattern, using this to eliminate the violation.
    public let fixing: String?
    /// Prompt of the violation to show as a notice.
    public let prompt: String
    /// The pattern of the contents rule.
    public var pattern: String
    /// Value of `ReportSeverity` indicates the warning or error.
    public var severity: ReportSeverity
}

// MARK: - RuleProtocol.

extension FileContentsRule: RuleProtocol {
    /// Lint the given path with the rule pattern.
    ///
    /// - Parameter path: The path to be validated.
    /// - Parameter config: The configuration of the lint target.
    /// - Parameter hit: Closure to be triggered when matching results.
    ///
    /// - Returns: Violations of the given path and all subpaths.
    public func lint(path: String, config: Configuration, hit: ((Violation) -> Void)?) throws -> [Violation] {
        guard try _checkingFileExists(at: path) == (true, false) else { return [] }
        
        let content = try String(contentsOf: URL(fileURLWithPath: path,
                                                 isDirectory: false),
                                 encoding: .utf8)
        return try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            .matches(in: content, options: [.reportCompletion], range: NSRange(location: 0, length: (content as NSString).length))
            .optionalMap { result in
                if let fixing = self.fixing {
                    // Find the line where the result lay on.
                    var totalLength = 0
                    let lines = content.components(separatedBy: .newlines).map { comp in
                        let range = NSRange(location: totalLength, length: (comp as NSString).length)
                        totalLength += range.length + 1
                        return range
                    }.filter { range in
                        return (result.range.location >= range.location
                            && (result.range.location + result.range.length) <= (range.location + range.length))
                    }.map { range in
                        (content as NSString).substring(with: range)
                    }
                    // Checking the fixing format.
                    if lines.count == 1 {
                        let line = lines.last!
                        // The fixing format should be the end of the range.
                        if NSPredicate(format: "SELF ENDSWITH[cd] '\(fixing)'").evaluate(with: line) {
                            return nil
                        }
                    }
                }
                
                let range = content.range(from: NSRange(location: 0, length: result.range.location))
                let prefix = content[range]
                let lines = prefix.components(separatedBy: .newlines)
                let violation = Violation(line: lines.count,
                                          character: (lines.last?.lengthOfBytes(using: .utf8) ?? 1) + 1,
                                          file: path,
                                          severity: severity,
                                          reason: "File Content Violation: \(prompt)\(fixing == nil ? "" : ", using `\(fixing!)` to ignore.")")
                hit?(violation)
                return violation
        }
    }
}
