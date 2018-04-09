//
//  RuleProtocol.swift
//  PathLintFramework
//
//  Created by devedbox on 2018/4/9.
//

public protocol RuleProtocol {
    var pattern: String { get set }
    var severity: ReportSeverity { get set }
    func lint(path: String, config: Configuration, hit: ((Violation) -> Void)?) throws -> [Violation]
}
