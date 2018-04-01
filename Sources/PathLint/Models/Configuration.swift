//
//  Configuration.swift
//  pathlint
//
//  Created by devedbox on 2018/4/1.
//

import Foundation

public struct Configuration: Decodable {
    let rules: [Rule]
    let excludes: [String] // The file directory to be excluded.
}

extension Configuration {
    public static func `default`() throws -> Configuration? {
        let fileManager = FileManager.default
        let cwd = getcwd()
        // Find `PathLint.json` if any.
        let configPath = cwd.path(byAppending: "PathLintFile")
        guard fileManager.fileExists(atPath: configPath) else {
            print("💔There is no configuration file exists.")
            return nil
        }
        
        // Load the content of the file.
        let configString = try String(contentsOfFile: configPath, encoding: .utf8)
        guard let configData = configString.data(using: .utf8) else {
            print("💔Invalid configuration content at \(cwd).")
            return nil
        }
        return try JSONDecoder().decode(Configuration.self, from: configData)
    }
}
