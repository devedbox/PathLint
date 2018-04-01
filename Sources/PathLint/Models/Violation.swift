//
//  Violation.swift
//  pathlint
//
//  Created by devedbox on 2018/4/1.
//

public struct Violation {
    let file: String
    let severity: Rule.Severity
    let reason: String
}

extension Violation: CustomStringConvertible {
    public var description: String {
        // {full_path_to_file}{:line}{:character}: {error,warning}: {content}
        return "\(file):1:1: \(severity.rawValue): \(reason)"
    }
}
