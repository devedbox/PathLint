//
//  misc.swift
//  PathLint
//
//  Created by devedbox on 2018/4/1.
//

#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation
import Dispatch

// MARK: - Public.

public func getcwd() -> String {
  return FileManager.default.currentDirectoryPath
}

public func asyncPrint<T>(_ t: T, on queue: DispatchQueue = DispatchQueue.main) { queue.async { print(t) } }
public func syncPrint<T>(_ t: T, on queue: DispatchQueue = DispatchQueue.main) { queue.sync { print(t) } }

public func lint(
  config: Configuration) throws -> [Violation]
{
  return try lint(try FileManager.default.nodes(in: getcwd(), filter: { path in
    config.excludes.filter { path.hasSuffix($0) }.isEmpty
  }), using: config)
}

public func lint(
  _ paths: [String],
  using config: Configuration) throws -> [Violation]
{
  defer {
    print("✅Lint Done!")
  }
  return try paths.flatMap { try lint(path: $0, using: config) }
}

public func lint(
  path: String,
  using config: Configuration) throws -> [Violation]
{
  return try config.rules.flatMap { rule in
    return try DispatchQueue.global(qos: .default).sync {
      try rule.lint(path: path, config: config)
    }
  }
}

public func execute(
  exit exitCode: Int32,
  throwing: () throws -> Void)
{
  do {
    try throwing()
  } catch let error {
    print(error); exit(exitCode)
  }
}

// MARK: - Internal.

internal func _checkingFileExists(
  at path: String) throws -> (Bool, Bool)
{
  var isDirectory: ObjCBool = false
  
  guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
    print("💔File does not exist at \(path).")
    return (exists: false, isDirectory: isDirectory.boolValue)
  }
  if
    isDirectory.boolValue,
    try FileManager.default.contentsOfDirectory(atPath: path).isEmpty
  {
    print("💔Empty contents at \(path).")
  }
  
  return (exists: true, isDirectory: isDirectory.boolValue)
}
