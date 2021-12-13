//
//  MigrationError.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation

enum MigrationError: LocalizedError {
    case fileDoesNotExist
    case fileAlreadyExists
    case invalidPermission
    case helperInstallation(String)
    case helperConnection(String)
    case notEnoughFree
    case unknown
    case noUserFoldersDetected
    
    var errorDescription: String? {
        switch self {
        case .fileDoesNotExist: return "The file or folder does not exist at the path given."
        case .invalidPermission: return "The Enterprise Migration Assistant does not have proper permissions to access that file or folder."
        case .helperInstallation(let description): return "Helper installation error, \(description)"
        case .helperConnection(let description): return "Helper connection error. \(description)"
        case .unknown: return "Unknown error"
        case .notEnoughFree: return "There is not enough free on the destination disk to perform the migration."
        case .noUserFoldersDetected: return "There were no user folders detected on the selected drive."
        case .fileAlreadyExists: return "The file already exists."
        }
    }
}
