//
//  String+Path.swift
//  PathLint
//
//  Created by devedbox on 2018/4/1.
//

import Foundation

extension String {
    public func path(byAppending path: String) -> String {
        return "\(self)\(self.hasSuffix("/") ? "" : "/")\(path)"
    }
}

extension String {
    internal func isUppercase() -> Bool {
        return self == uppercased()
    }
}
