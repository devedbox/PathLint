//
//  Configuration.swift
//  pathlint
//
//  Created by devedbox on 2018/4/1.
//

import Foundation
import Yams

// MARK: - ConfigurationError.

/// Error type represents the error info of configuration domain.
public enum ConfigurationError: String, Error {
  /// Indicates the file does not exist at the given path.
  case fileNotExists = "There is no configuration file exists."
  /// Indicates the data of the file is invalid.
  case invalidData = "Invalid configuration data."
}

// MARK: - Configuration.

/// A type represents the only configuration of the whole lint target, a configuration consists of
/// the basic path pattern, global contents rule, rules to lint paths and excludes path to be excluded.
///
/// The configuration contains rules and excludes, and basic pattern. Using the basic pattern can
/// optimize the size of the configuration file.
public struct Configuration: Decodable {
  /// Coding keys of `Configuration`.
  internal enum CodingKeys: String, CodingKey {
    /// Coding key for `base_pattern`.
    case basePattern = "base-file-pattern"
    /// Coding key for `global_content_rules`.
    case globalContentRules = "file-content-rules"
    /// Coding key for `rules`.
    case rules = "file-rules"
    /// Coding key for `excludes`.
    case excludes
  }
  /// Basic pattern to be used commonality.
  let basePattern: String
  /// Global content rules to verify each file of the given path.
  let globalContentRules: [FileContentsRule]?
  /// Rules of path lints.
  let rules: [PathRule]
  /// Excluding paths.
  let excludes: [String] // The file directory to be excluded.
}

// MARK: -

extension Configuration {
  public static func `default`() throws -> Configuration {
    return try config(at: getcwd())
  }
}

// MARK: -

extension Configuration {
  public static func config(
    at path: String) throws -> Configuration
  {
    let fileManager = FileManager.default
    // Find `PathLint.json` if any.
    let configPath = path.path(byAppending: ".pathlint.yml")
    guard fileManager.fileExists(atPath: configPath) else {
      print("💔There is no configuration file exists.")
      throw ConfigurationError.fileNotExists
    }
    
    // Load the content of the file.
    let configString = try String(contentsOfFile: configPath, encoding: .utf8)
    return try YAMLDecoder().decode(Configuration.self, from: configString)
  }
}
