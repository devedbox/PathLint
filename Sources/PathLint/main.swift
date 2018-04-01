//
//  main.swift
//  PathLint
//
//  Created by devedbox on 2018/4/1.
//

import Foundation

// Find the current working directionary.
let cwd = "/Users/devedbox/Library/Mobile Documents/com~apple~CloudDocs/Development/PathLint"
do {
    try findPathsRecursively(at: cwd) {
        print($0)
    }
} catch let error {
    print(error)
}
