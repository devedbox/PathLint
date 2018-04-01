//
//  main.swift
//  PathLint
//
//  Created by devedbox on 2018/4/1.
//

do {
    try findPathsRecursively(at: "/Users/devedbox/Library/Mobile Documents/com~apple~CloudDocs/Development/PathLint") {
        print($0)
    }
} catch let error {
    print(error)
}
