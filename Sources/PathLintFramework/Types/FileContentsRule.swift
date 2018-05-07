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
    public let fixing: String?
    public let prompt: String
    public var pattern: String
    public var severity: ReportSeverity
}

extension FileContentsRule {
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
                                          reason: "File Content Violation: \(prompt)")
                hit?(violation)
                return violation
        }
    }
}
