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
        self.logger.info("Beginning file move process...")
        
        self.logger.info("Creating hidden folder.")
        self.createHiddenFolder(newUser) {
            self.logger.info("Delete existing user.")
            self.deleteExistingUserFolder(newUser) {
                self.logger.info("Moving files")
                self.moveFiles(from: "/Users/migrator-\(newUser)", to: "/Users/\(newUser)") {
                    self.logger.info("Creating account.")
                    self.createAccount(user: newUser, password: password) {
                        self.logger.info("Fixing permissions")
                        self.fixPermissions(user: newUser) {
                            self.logger.info("Changing ownership.")
                            self.changeOwner(user: newUser) {
                                exit(0)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createHiddenFolder(_ user: String, then completion: @escaping () -> Void) {
        do {
            try ToolExecutionService.createHidden(user: user) { (output, error) in
                if let error = error {
                    self.logger.error("Obtained an error \(error.localizedDescription, privacy: .public) while attempting to create hidden folder.")
                    self.error = error
                    exit(101)
                } else {
                    self.logger.info("Obtained a response of \(output ?? "", privacy: .public) while attempting to create hidden folder.")
                    completion()
                }
            }
        } catch {
            self.logger.error("Obtained an error while trying to execute the hidden folder creation function. Error: \(error.localizedDescription, privacy: .public)")
            self.error = error
            exit(101)
        }
    }
    
    func deleteExistingUserFolder(_ user: String, then completion: @escaping () -> Void) {
        do {
            try ToolExecutionService.delete(user: user) { (output, error) in
                if let error = error {
                    self.logger.error("Obtained an error \(error.localizedDescription, privacy: .public) while attempting to delete existing user's folder.")
                    self.error = error
                    exit(102)
                } else {
                    self.logger.info("Obtained a response of \(output ?? "", privacy: .public) while attempting to delete existing user's folder.")
                    completion()
                }
            }
        } catch {
            self.logger.error("Obtained an error while trying to execute the user deletion function. Error: \(error.localizedDescription, privacy: .public)")
            exit(102)
        }
    }
    
    func moveFiles(from src: String, to dst: String, then completion: @escaping () -> Void) {
        ToolExecutionService.moveFiles(from: src, to: dst) { (output, error) in
            if let error = error {
                self.logger.error("Obtained an error \(error.localizedDescription, privacy: .public) while attempting to move folder \(src, privacy: .public) to \(dst, privacy: .public)")
                self.error = error
                exit(103)
            } else {
                self.logger.info("Obtained a response of \(output ?? "", privacy: .public)")
                completion()
            }
        }
    }
    
    func fixPermissions(user: String, then completion: @escaping () -> Void) {
        do {
            try ToolExecutionService.fixPermissions(for: user) { (output, error) in
                if let error = error {
                    self.logger.error("Obtained an error \(error.localizedDescription, privacy: .public) while attempting to fix permissions on the user's folder.")
                    self.error = error
                    exit(104)
                } else {
                    self.logger.info("Obtained a response of \(output ?? "", privacy: .public)")
                    completion()
                }
            }
        } catch {
            self.logger.error("Obtained an error while trying to execute permission fix function. Error: \(error.localizedDescription, privacy: .public)")
            exit(104)
        }
    }
    
    func createAccount(user: String, password: String, adminUser: String = "migrator", adminPassword: String = "migrationisfun", then completion: @escaping () -> Void) {
        do {
            // TODO: Remove password output to ensure no sensitive data is leaked.
            self.logger.info("Attempting to create \(user, privacy: .public) with a password of \(password, privacy: .public).")
            try ToolExecutionService.create(user: user, withPassword: password, migratorUser: adminUser, migratorPassword: adminPassword) { (output, error) in
                if let error = error {
                    self.logger.error("Obtained an error \(error.localizedDescription, privacy: .public) while attempting to create user \(user, privacy: .public).")
                    self.error = error
                    exit(105)
                } else {
                    self.logger.info("Obtained a response of \(output ?? "", privacy: .public)")
                    completion()
                }
            }
        } catch {
            self.logger.error("Obtained an error while trying to execute account creation function. Error: \(error.localizedDescription, privacy: .public)")
            self.error = error
            exit(105)
        }
    }
    
    func changeOwner(user: String, then completion: @escaping () -> Void) {
        do {
            try ToolExecutionService.updateOwner(to: user, for: "/Users/\(user)") { (output, error) in
                if let error = error {
                    self.logger.error("Obtained an error \(error.localizedDescription, privacy: .public) while attempting to update owner information.")
                    self.error = error
                    exit(106)
                } else {
                    self.logger.info("Obtained a response of \(output ?? "", privacy: .public)")
                    completion()
                }
            }
        } catch {
            self.error = error
            self.logger.error(("Obtained an error while trying to execute owner update function. Error: \(error.localizedDescription, privacy: .public)"))
            exit(106)
        }
    }
    
}
