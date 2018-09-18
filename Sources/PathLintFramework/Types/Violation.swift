//
//  Violation.swift
//  pathlint
//
//  Created by devedbox on 2018/4/1.
//

// MARK: - Violation.

/// A type represents the rule's violaion contains the line, character, file name,
/// report severity and violation reason of the rule.
public struct Violation {
  /// Line number of the violation.
  public let line: Int
  /// Character number of the violation.
  public let character: Int
  /// File name of the violation.
  public let file: String
  /// Report severity of the violation.
  public let severity: ReportSeverity
  /// The reason of the violatiom.
  public let reason: String
  /// Creates a `Violation` with given parameters.
  ///
  /// - Parameter line: The line number of the violation. Defaults to 1.
  /// - Parameter character: The character number of the violation. Defautls to 1.
  /// - Parameter severity: The severity level of the violation.
  /// - Parameter reason: The reason of the violation.
  public init(
    line: Int = 1,
    character: Int = 1,
    file: String,
    severity: ReportSeverity,
    reason: String)
  {
    self.line = line
    self.character = character
    self.file = file
    self.severity = severity
    self.reason = reason
  }
}

// MARK: - CustomStringConvertible.

extension Violation: CustomStringConvertible {
  /// Returns the description content of the violation.
  public var description: String {
    // {full_path_to_file}{:line}{:character}: {error,warning}: {content}
    return "\(file):\(line):\(character): \(severity.rawValue): \(reason)"
  }
}
