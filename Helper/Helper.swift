//
//  Helper.swift
//  com.github.cybertunnel.Enterprise-Migration-Assistant.helper
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation

class Helper: NSObject, NSXPCListenerDelegate, HelperProtocol {
    func startLaunchDaemon() {
        // Start the launchdaemon
    }
    
    func copyFolder(from src: URL, to dest: URL, then completion: @escaping (String?, Error) -> Void) {
        print("Copied")
    }
    
    
    //  MARK: - Properties
    
    let listener: NSXPCListener
    
    // MARK: - Initialisation
    
    override init() {
        self.listener = NSXPCListener(machServiceName: HelperConstants.domain)
        super.init()
        self.listener.delegate = self
    }
    
    // MARK: - Functions // MARK: HelperProtocol
    
    // TODO: Add proper functions
    func createMigrationUser(username: String = "migrator", withName name: String = "Please Wait...", withPassword password: String = "migrationisfun", usingAdmin adminUser: String, withAdminPass adminPass: String, then completion: @escaping (String?, Error?) -> Void) {
        logger.info("Attempting to make \(username) user using \(adminUser)'s credentials.")
        do {
            try HelperExecutionService.makeMigratorUser(username: username, withName: name, withPassword: password, usingAdmin: adminUser, withAdminPass: adminPass) { (result) in
                logger.info("Output: \(result.string ?? ""). Error: \(result.error?.localizedDescription ?? "")")
                completion(result.string, result.error)
            }
        } catch {
            logger.info("Error: \(error.localizedDescription)")
            completion(nil, error)
        }
    }
    
    func createLaunchDaemon(migratorToolPath path: String, withOldUser oldUser: String, withOldHome oldHome: String, withOldPass oldPass: String, forUser user: String, then completion: @escaping (String?, Error?) -> Void) {
        logger.info("Attempting to create launch daemon to launch the tool at \(path)")
        
        HelperExecutionService.createLaunchDaemon(migratorToolPath: path, withOldUser: oldUser, withOldHome: oldHome, withOldPass: oldPass, forUser: user) { (result) in
            logger.info("Output: \(result.string ?? ""). Error: \(result.error?.localizedDescription ?? "")")
            completion(result.string, result.error)
        }
    }
    
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
