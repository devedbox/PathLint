//
//  Violation.swift
//  pathlint
//
//  Created by devedbox on 2018/4/1.
//

public struct Violation {
    public let line: Int
    public let character: Int
    public let file: String
    public let severity: ReportSeverity
    public let reason: String
    
    init(line: Int = 1, character: Int = 1, file: String, severity: ReportSeverity, reason: String) {
        self.line = line
        self.character = character
        self.file = file
        self.severity = severity
        self.reason = reason
    }
}

extension Violation: CustomStringConvertible {
    public var description: String {
        // {full_path_to_file}{:line}{:character}: {error,warning}: {content}
        return "\(file):\(line):\(character): \(severity.rawValue): \(reason)"
    }
}
