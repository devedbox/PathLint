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

extension String {
    public func range(from nsrange: NSRange) -> Range<String.Index> {
        let start = utf16.index(utf16.startIndex, offsetBy: nsrange.location, limitedBy: utf16.endIndex)!
        let end = utf16.index(start, offsetBy: nsrange.length, limitedBy: utf16.endIndex)!
        
        return start..<end
    }
}
