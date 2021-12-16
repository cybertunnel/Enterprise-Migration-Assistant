//
//  Helper.swift
//  com.github.cybertunnel.Enterprise-Migration-Assistant.helper
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation
import OSLog

class Helper: NSObject, NSXPCListenerDelegate, HelperProtocol {
    
    private let logger = Logger(subsystem: AppConstants.bundleIdentifier, category: "Migration Helper")
    func startLaunchDaemon(then completion: @escaping (String?, Error?) -> Void) {
        self.logger.info("Attempting to start the LaunchDaemon...")
        HelperExecutionService.startLaunchDaemon() { (result) in
            completion(result.string, result.error)
        }
    }
    
    func copyFolder(from src: URL, to dest: URL, then completion: @escaping (String?, Error?) -> Void) {
        HelperExecutionService.copyFolder(from: src, to: dest) { (result) in
            self.logger.debug("Obtained result of \(String(describing: result.string.debugDescription), privacy: .public) and \(String(describing: result.error?.localizedDescription.debugDescription), privacy: .public)")
            completion(result.string, result.error)
        }
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
    
    func createLaunchDaemon(migratorToolPath path: String, withOldUser oldUser: String, withOldHome oldHome: String, withOldPass oldPass: String, forUser user: String, then completion: @escaping (String?, Error?) -> Void) {
        self.logger.info("Attempting to create launch daemon to launch the tool at \(path)")
        
        HelperExecutionService.createLaunchDaemon(migratorToolPath: path, withOldUser: oldUser, withOldHome: oldHome, withOldPass: oldPass, forUser: user) { (result) in
            self.logger.info("Output: \(result.string ?? ""). Error: \(result.error?.localizedDescription ?? "")")
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
