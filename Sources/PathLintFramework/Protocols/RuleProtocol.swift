//
//  RuleProtocol.swift
//  PathLintFramework
//
//  Created by devedbox on 2018/4/9.
//

// MARK: - RuleProtocol.

/// A protocol represents the conforming types can validate the name or content of the given path
/// with the `pattern` and `severity` to generate the violation results of the path and its subpaths.
public protocol RuleProtocol {
  /// Rule pattern to validate the path.
  var pattern: String { get set }
  /// Value of `ReportSeverity` indicates the warning or error.
  var severity: ReportSeverity { get set }
  /// Lint the given path with the rule pattern.
  ///
  /// - Parameter path: The path to be validated.
  /// - Parameter config: The configuration of the lint target.
  /// - Parameter hit: Closure to be triggered when matching results.
  ///
  /// - Returns: Violations of the given path and all subpaths.
  func lint(path: String, config: Configuration, hit: ((Violation) -> Void)?) throws -> [Violation]
}
