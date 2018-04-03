//
//  main.swift
//  PathLint
//
//  Created by devedbox on 2018/4/1.
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif
import PathLintFramework
    
do {
    exit(try lint(config: try Configuration.default()).filter { $0.severity == .error }.isEmpty ? 0 : 1)
} catch let error {
    print(error)
    exit(2)
}
