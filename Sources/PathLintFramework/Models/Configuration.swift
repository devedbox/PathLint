//
//  Configuration.swift
//  pathlint
//
//  Created by devedbox on 2018/4/1.
//

import Foundation
import Yams

public enum ConfigurationError: String, Error {
    case fileNotExists = "There is no configuration file exists."
    case invalidData = "Invalid configuration data."
}

public struct Configuration: Decodable {
    let rules: [Rule]
    let excludes: [String] // The file directory to be excluded.
}

extension Configuration {
    public static func `default`() throws -> Configuration {
        return try config(at: getcwd())
    }
}

extension Configuration {
    public static func config(at path: String) throws -> Configuration {
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
