//
//  Sequence+OptionalMap.swift
//  PathLintFramework
//
//  Created by devedbox on 2018/4/12.
//

extension Sequence {
    public func optionalMap<ElementOfResult>(_ transform: (Self.Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        #if swift(>=4.1)
        return try compactMap(transform)
        #else
        return try flatMap(transform)
        #endif
    }
}
