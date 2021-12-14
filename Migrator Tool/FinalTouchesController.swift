//
//  FinalTouchesController.swift
//  Migrator Tool
//
//  Created by Morgan, Tyler on 12/14/21.
//

import Foundation
import OSLog
import AppKit

class FinalTouchesController: ObservableObject {
    
    @Published var error: Error? = nil
    private let logger = Logger(subsystem: "com.github.cybertunnel.Enterprise-Migration-Assistant.Migration Tool", category: "Final Touch Controller")
    
    init(loggedInUser user: String, username newUser: String, password: String) {
        DispatchQueue(label: "Background Functions", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil).async {
            do {
                try self.start(loggedInUser: user, username: newUser, password: password)
            } catch {
                self.error = error
            }
        }
    }
    
    func start(loggedInUser user: String, username newUser: String, password: String) throws {
        let migrationPassword = "migrationisfun"
        let migrationUser = "migrator"
        self.logger.info("Beginning final touches for the logged in user of \(user, privacy: .public) and creating the final user of \(newUser, privacy: .public)")
        
        self.logger.info("Creating hidden folder for \(newUser)")
        // MARK: - Creating hidden folder
        try ToolExecutionService.createHidden(user: newUser) { (output, error) in
            if let error = error {
                self.logger.error("Obtained an error of \(error.localizedDescription, privacy: .public)")
                exit(1)
            }
            else {
                self.logger.info("Got a response of \(output ?? "", privacy: .public)")
                // TODO: Check to see if user exists
                
                self.logger.info("Attempting to delete user \(user, privacy: .public)")
                // MARK: - Deleting old user
                do {
                    try ToolExecutionService.delete(user: newUser) { (output, error) in
                        if let error = error {
                            self.logger.error("Obtained an error of \(error.localizedDescription)")
                            exit(2)
                        } else {
                            self.logger.info("Got a response of \(output ?? "", privacy: .public)")
                            
                            self.logger.info("Moving the temp folder to it's final resting place.")
                            // MARK: - Moving user folder over
                            ToolExecutionService.moveFiles(from: "/Users/migrator-\(newUser)", to: "/Users/\(newUser)") { (output, error) in
                                if let error = error {
                                    self.logger.error("Obtained an error of \(error.localizedDescription, privacy: .public)")
                                } else {
                                    self.logger.info("Got a response of \(output ?? "", privacy: .public)")
                                    
                                    // MARK: - Update Permissions
                                    self.logger.info("Attempting to fix permissions.")
                                    do {
                                        try ToolExecutionService.fixPermissions(for: "/Users/\(newUser)") { (output, error) in
                                            if let error = error {
                                                self.logger.error("Obtained an error of \(error.localizedDescription, privacy: .public)")
                                                exit(4)
                                            } else {
                                                self.logger.info("Got a response of \(output ?? "", privacy: .public)")
                                                
                                                self.logger.info("Attempting to change owner of the folder.")
                                                do {
                                                    try ToolExecutionService.updateOwner(to: newUser, for: "/Users/\(newUser)") { (output, error) in
                                                        if let error = error {
                                                            self.logger.error("Obtained an error of \(error.localizedDescription, privacy: .public)")
                                                            exit(5)
                                                        } else {
                                                            self.logger.info("Got a respons of \(output ?? "", privacy: .public)")
                                                        }
                                                    }
                                                } catch {
                                                    self.logger.error("Obtained an error of \(error.localizedDescription, privacy: .public)")
                                                    exit(5)
                                                }
                                            }
                                        }
                                    } catch {
                                        self.logger.error("Obtained an error of \(error.localizedDescription, privacy: .public)")
                                        exit(4)
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    self.logger.error("Obtained an error of \(error.localizedDescription)")
                }
            }
        }
    }
    
    
}
