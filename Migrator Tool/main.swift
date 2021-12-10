//
//  main.swift
//  Migrator Tool
//
//  Created by Morgan, Tyler on 12/10/21.
//

import Foundation

enum MigratorToolError: Error {
    case InvalidNumberOfParameters
}

let arguments = Array(CommandLine.arguments.dropFirst())

if arguments.count < 4 { throw MigratorToolError.InvalidNumberOfParameters }
