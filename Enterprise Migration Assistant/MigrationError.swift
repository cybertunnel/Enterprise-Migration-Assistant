//
//  MigrationError.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation

enum MigrationError: LocalizedError {
    case fileDoesNotExist
    case invalidPermission
    case helperInstallation(String)
    case helperConnection(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .fileDoesNotExist: return "The file or folder does not exist at the path given."
        case .invalidPermission: return "The Enterprise Migration Assistant does not have proper permissions to access that file or folder."
        case .helperInstallation(let description): return "Helper installation error, \(description)"
        case .helperConnection(let description): return "Helper connection error. \(description)"
        case .unknown: return "Unknown error"
        }
    }
}
