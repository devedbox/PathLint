//
//  Rule.swift
//  pathlint
//
//  Created by devedbox on 2018/4/1.
//

public struct Rule: Decodable {
    public enum Severity: String, Decodable {
        case warning
        case error
    }
    
    let path: String // The file directory end node: Models/
    let pattern: String // The pattern to lint the file name: [a-zA-Z0-9_-+]Model.swift
    
    let uppercasePrefix: Bool
    let severity: Severity
    
    let ignores: [String]
}
