//
//  ExecutionService.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation
import SwiftUI

struct ExecutionService {
    
    // MARK: - Constants
    
    typealias Handler = (Result<String, Error>) -> Void
    
    static func makeMigratorUser(_ username: String = "migrator", withName name: String = "Please Wait...", withPassword password: String = "migrationisfun", usingAdmin admin: User, then completion: @escaping Handler) throws {
        let remote = try HelperRemote().getRemote()
        
        remote.createMigrationUser(username: username, withName: name, withPassword: password, usingAdmin: admin.username, withAdminPass: admin.localPassword) { (output, error) in
            completion(Result(string: output, error: error))
        }
    }
    
    static func createLaunchDaemon(migratorToolPath path: String, withOldUser oldUser: String, withOldHome oldHome: String, withOldPass oldPass: String, forUser user: String, then completion: @escaping Handler) throws {
        let remote = try HelperRemote().getRemote()
        
        remote.createLaunchDaemon(migratorToolPath: path, withOldUser: oldUser, withOldHome: oldHome, withOldPass: oldPass, forUser: user) { (output, error) in
            old_logger.info("Got a response: \(String(describing: output))")
            completion(Result(string: output, error: error))
        }
    }
    
    static func moveFolder(from srcFolder: URL, to destFolder: URL, then completion: @escaping Handler) throws {
        if FileManager.default.fileExists(atPath: destFolder.path) {
            completion(.failure(MigrationError.fileAlreadyExists))
        } else {
            if FileManager.default.fileExists(atPath: destFolder.path) {
                do {
                    try FileManager.default.copyItem(at: srcFolder, to: destFolder)
                } catch {
                    let remote = try HelperRemote().getRemote()
                    
                    remote.copyFolder(from: srcFolder, to: destFolder) { (output, error) in
                        old_logger.debug("Got response of \(output ?? "")")
                        completion(Result(string: output, error: error))
                    }
                }
            } else {
                completion(.failure(MigrationError.fileDoesNotExist))
            }
        }
    }
    
    
}
