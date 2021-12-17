//
//  ExecutionService.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation
import OSLog

/**
 Execution object to help abstract the underlying functions and the calls out to the helper.
 - SeeAlso: `HelperExecutionService` and `ToolExecutionService`
 */
struct ExecutionService {
    
    // MARK: - Constants
    
    typealias Handler = (Result<String, Error>) -> Void
    static let logger = Logger(subsystem: AppConstants.bundleIdentifier, category: "Execution Service")
    
    
    // MARK: - Functions
    
    /**
     Make the migration user using the provided information
     - Parameters:
        - username: The migration user's username as `String`. Default: `migrator`
        - name: The Full Name of the migration user account as `String`. Default: `Please Wait...`
        - password: The password for the new migration account as `String`. Default: `migrationisfun`
        - admin: The admin user being used to create the migration account.
        - completion: The handler for when this function completes as `(Result<String, Error>) -> Void`
     - Throws: `MigrationError` if there is an issue with the helper.
     */
    static func makeMigratorUser(_ username: String = "migrator", withName name: String = "Please Wait...", withPassword password: String = "migrationisfun", usingAdmin admin: User, then completion: @escaping Handler) throws {
        let remote = try HelperRemote().getRemote()
        
        remote.createMigrationUser(username: username, withName: name, withPassword: password, usingAdmin: admin.username, withAdminPass: admin.localPassword) { (output, error) in
            completion(Result(string: output, error: error))
        }
    }
    
    /**
     Create a launch daemon for the migrator tool at the provided path and arguments
     - Parameters:
        - path: The path of the migration tool as `String`
        - oldUser: The user's old account name as `String`
        - oldHome: The user's temporary migrated data folder path as `String`
        - oldPass: The user's password on their old device as `String`
        - user: The user that will be created as `String`
     - Throws: `MigrationError` if there is an issue with the helper.
     */
    static func createLaunchDaemon(migratorToolPath path: String, withOldUser oldUser: String, withOldHome oldHome: String, withOldPass oldPass: String, forUser user: String, then completion: @escaping Handler) throws {
        let remote = try HelperRemote().getRemote()
        
        remote.createLaunchDaemon(migratorToolPath: path, withOldUser: oldUser, withOldHome: oldHome, withOldPass: oldPass, forUser: user) { (output, error) in
            self.logger.info("Got a response: \(String(describing: output))")
            completion(Result(string: output, error: error))
        }
    }
    
    /**
     Start the created launch daemon
     - Parameters:
        - completion: The handler for when this function completes as `(Result<String, Error>) -> Void`
     - Throws: `MigrationError` if there is an issue with the helper.
     */
    static func startLaunchDaemon(then completion: @escaping Handler) throws {
        let remote = try HelperRemote().getRemote()
        
        remote.startLaunchDaemon() { (output, error) in
            self.logger.info("Got a response: \(String(describing: output))")
            completion(Result(string: output, error: error))
        }
    }
    
    /**
     Move the provided folder to a provided location.
     - Parameters:
        - srcFolder: The folder which is being copied to `destFolder` as `URL`
        - destFolder: The folder URL which `srcFolder` will be moved to as `URL`
        - completion: The handler for when an error or data is recieved as `(Result<String, Error>) -> Void`
     - Throws: `MigrationError` if there is an issue with the helper.
     */
    static func moveFolder(from srcFolder: URL, to destFolder: URL, then completion: @escaping Handler) throws {
        logger.info("Recieved request to copy \(srcFolder.debugDescription) to \(destFolder.debugDescription)")
        
        logger.info("Checking if destination file(s) or folder(s) exist already.")
        if FileManager.default.fileExists(atPath: destFolder.path) {
            logger.error("File/Folder at \(destFolder.path) already exists")
            completion(.failure(MigrationError.fileAlreadyExists))
            return
        }
        
        logger.info("Checking if source file(s) or folder(s) exists.")
        if !FileManager.default.fileExists(atPath: srcFolder.path) {
            logger.error("File/Folder at \(srcFolder.path) does not exist.")
            completion(.failure(MigrationError.fileDoesNotExist))
            return
        }
        
        logger.info("Checking if we have write permissions")
        if FileManager.default.createFile(atPath: destFolder.path, contents: nil, attributes: nil) {
            logger.debug("We have write permissions!")
            do {
                try FileManager.default.removeItem(atPath: destFolder.path)
            } catch {
                logger.error("Obtained error of \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
        } else {
            logger.error("We do not have write permissions")
            // Attempt to contact the helper to perform action
            logger.info("Attempting to contact the little helper to help")
            do {
                let remote = try HelperRemote().getRemote()
                
                remote.copyFolder(from: srcFolder, to: destFolder) { (output, error) in
                    guard let output = output else { completion(.failure(error ?? MigrationError.unknown)); return }
                    
                    logger.info("Obtained response from our little friend of \(output)")
                    completion(.success(output))
                }
            }
            
            return
        }
    }
    
    
}
