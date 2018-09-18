//
//  ReportSeverity.swift
//  PathLintFramework
//
//  Created by devedbox on 2018/4/9.
//

// MARK: - ReportSeverity.

/// A type represents the report type of the lint result.
public enum ReportSeverity: String, Decodable {
  /// Value indicates the warnings of the lint result.
  case warning
  /// Value indicates the errors of the lint result.
  case error
}
