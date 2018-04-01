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
    
do {
    if  let config = try Configuration.default() {
        let violations = try findPathsRecursively(using: config).flatMap { try lint(path: $0, using: config) }
        print("✅Lint Done!")
        
        if violations.filter({ $0.severity == .error }).isEmpty {
            exit(0)
        } else {
            exit(1)
        }
    }
    
    exit(0)
} catch let error {
    print(error)
    exit(2)
}
