//
//  Helper.swift
//  com.github.cybertunnel.Enterprise-Migration-Assistant.helper
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation
import OSLog

/**
 Privileged helper for handling elevated tasks
 */
class Helper: NSObject, NSXPCListenerDelegate, HelperProtocol {
    
    /// Logging object
    private let logger = Logger(subsystem: AppConstants.bundleIdentifier, category: "Migration Helper")
    
    /**
     Start the launch daemon
     
     - Parameters:
        - completion: Do this after the launch daemon loads
     */
    func startLaunchDaemon(then completion: @escaping (String?, Error?) -> Void) {
        self.logger.info("Attempting to start the LaunchDaemon...")
        HelperExecutionService.startLaunchDaemon() { (result) in
            completion(result.string, result.error)
        }
    }
    
    /**
     Copy the provided folder to the provided destination
     
     - Parameters:
        - src: The folder being copied as `URL`
        - dest: The place the folder is being copied to as `URL`
        - completion: What to do when data or errors are recieved as `(String?, Error?) -> Void`
     */
    func copyFolder(from src: URL, to dest: URL, then completion: @escaping (String?, Error?) -> Void) {
        HelperExecutionService.copyFolder(from: src, to: dest) { (result) in
            self.logger.debug("Obtained result of \(String(describing: result.string.debugDescription), privacy: .public) and \(String(describing: result.error?.localizedDescription.debugDescription), privacy: .public)")
            completion(result.string, result.error)
        }
    }
    
    
    //  MARK: - Properties
    
    /// The spy
    let listener: NSXPCListener
    
    // MARK: - Initialisation
    
    override init() {
        self.listener = NSXPCListener(machServiceName: HelperConstants.domain)
        super.init()
        self.listener.delegate = self
    }
    
    // MARK: - Functions // MARK: HelperProtocol
    
    // TODO: Add proper functions
    
    /**
     Create a migration user with the provided information using the provided credentials
     
     - Parameters:
        - username: The username for the migration user as `String`. Default: `migrator`
        - name: The full name of the migration user as `String`. Default: `Please Wait...`
        - password: The password for the migration account as `String`. Default: `migrationisfun`
        - adminUser: The username of the admin user being used to create this account as `String`
        - adminPass: The password for the admin user being used to create this account as `String`
        - completion: What to do when data or error is recieved as `(String?, Error?) -> Void`
     */
    func createMigrationUser(username: String = "migrator", withName name: String = "Please Wait...", withPassword password: String = "migrationisfun", usingAdmin adminUser: String, withAdminPass adminPass: String, then completion: @escaping (String?, Error?) -> Void) {
        self.logger.info("Attempting to make \(username) user using \(adminUser)'s credentials.")
        do {
            try HelperExecutionService.makeMigratorUser(username: username, withName: name, withPassword: password, usingAdmin: adminUser, withAdminPass: adminPass) { (result) in
                self.logger.info("Output: \(result.string ?? ""). Error: \(result.error?.localizedDescription ?? "")")
                completion(result.string, result.error)
            }
        } catch {
            self.logger.info("Error: \(error.localizedDescription)")
            completion(nil, error)
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
        - completion: What to do when data or error is recieved as `(String?, Error?) -> Void`
     */
    func createLaunchDaemon(migratorToolPath path: String, withOldUser oldUser: String, withOldHome oldHome: String, withOldPass oldPass: String, forUser user: String, then completion: @escaping (String?, Error?) -> Void) {
        self.logger.info("Attempting to create launch daemon to launch the tool at \(path)")
        
        HelperExecutionService.createLaunchDaemon(migratorToolPath: path, withOldUser: oldUser, withOldHome: oldHome, withOldPass: oldPass, forUser: user) { (result) in
            self.logger.info("Output: \(result.string ?? ""). Error: \(result.error?.localizedDescription ?? "")")
            completion(result.string, result.error)
        }
    }
    
    /// Run the helper
    func run() {
        //  Start listening on new connections
        self.listener.resume()
        // prevent the terminal application from exiting
        RunLoop.current.run()
    }
    
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        newConnection.remoteObjectInterface = NSXPCInterface(with: RemoteApplicationProtocol.self)
        newConnection.exportedObject = self

        newConnection.resume()

        return true
    }
}
