//
//  FileContentsRule.swift
//  PathLintFramework
//
//  Created by devedbox on 2018/4/9.
//

import Foundation

public enum FileContentsRuleError: CustomStringConvertible, Error {
    case invalidContents(path: String)
    
    public var description: String {
        switch self {
        case .invalidContents(path: let path):
            return "The contents at '\(path)' is invalid."
        }
    }
}

public struct FileContentsRule: RuleProtocol, Decodable {
    /// The violation fixing pattern.
    public let fixing: String
    public let prompt: String
    public var pattern: String
    public var severity: ReportSeverity
}

extension FileContentsRule {
    public func lint(path: String, config: Configuration, hit: ((Violation) -> Void)?) throws -> [Violation] {
        guard _checkingFileExists(at: path) == (true, false) else { return [] }
        
        let content = try String(contentsOf: URL(fileURLWithPath: path,
                                                 isDirectory: false),
                                 encoding: .utf8)
        return try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            .matches(in: content, options: [.reportCompletion], range: NSRange(location: 0, length: (content as NSString).length))
            .flatMap {
                guard
                    try NSRegularExpression(pattern: "\(pattern)\\s//\\s\(NSRegularExpression.escapedPattern(for: fixing))",
                        options: [.caseInsensitive])
                        .matches(in: content,
                                 options: [.reportCompletion],
                                 range: NSRange(location: $0.range.location,
                                                length: max((content as NSString).length - $0.range.location, $0.range.length
                                                    + (fixing as NSString).length
                                                    + 4)))
                        .isEmpty
                else {
                    return nil
                }
                let range = content.range(from: NSRange(location: 0, length: $0.range.location))
                let prefix = content[range]
                let lines = prefix.components(separatedBy: .newlines)
                let violation = Violation(line: lines.count,
                                          character: (lines.last?.lengthOfBytes(using: .utf8) ?? 1) + 1,
                                          file: path,
                                          severity: severity,
                                          reason: "File Content Violation: \(prompt)")
                hit?(violation)
                return violation
        }
    }
}
