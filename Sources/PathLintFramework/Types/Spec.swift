//
//  Spec.swift
//  PathLintFramework
//
//  Created by devedbox on 2018/5/8.
//

// MARK: - Spec.

/// A type represents the info of `PathLintFramework`.
public struct Spec { }
/// The global instance of `PathLintFramework`.
public let spec = Spec()

// MARK: -

extension Spec {
  /// Returns the current version of `PathLintFramework`.
  public var version: String {
    return "0.0.7"
  }
}
