//
//  User.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 11/18/21.
//

import Foundation
import AppKit

/**
 User object that is used by the MigrationController to understand the user being migrated.
 */
class User: Hashable, ObservableObject {
    
    // MARK: - Properties
    
    /// The username of the user that is being migrated
    let username: String
    
    /// The user's local folder
    @Published var localFolder: Folder?
    
    /// The user's remote folder
    @Published var remoteFolder: Folder?
    
    /// The user's remote password
    @Published var remotePassword: String = "" {
        didSet {
            guard let path = self.remoteFolder?.urlPath.path else { return }
            self.verifyRemotePassword(using: remotePassword, at: "\(path)/Library/Keychains/login.keychain-db")
        }
    }
    
    /// Is the user's remote password verified correct?
    @Published var remotePasswordVerified: Bool = false
    
    /// The user's local password
    @Published var localPassword: String = "" {
        didSet {
            self.verifyLocalPassword(with: localPassword)
        }
    }
    
    /// Is the user's local password verified correct?
    @Published var localPasswordVerified: Bool = false
    
    /// Does this user have a secure token?
    @Published var hasSecureToken: Bool = false
    
    // MARK: - Initialiser
    /**
     Creates a user object
     - Parameters:
        - username: The username of the user that will be migrated.
     */
    init(_ username: String) {
        self.username = username
        guard let homeDir = FileManager.default.homeDirectory(forUser: username) else { return }
        self.localFolder = Folder(name: homeDir.path, urlPath: homeDir)
    }
    
    // MARK: - Static Functions
    
    /// Detect the current user and creates a user object
    static func detectUser() -> User {
        let currUserHomeDir = FileManager.default.homeDirectoryForCurrentUser
        guard let currUser = currUserHomeDir.path.split(separator: "/").last else { return User("")}
        return User(String(describing: currUser))
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        if (lhs.remotePasswordVerified == rhs.remotePasswordVerified &&
            lhs.remotePassword == rhs.remotePassword &&
            lhs.hasSecureToken == rhs.hasSecureToken &&
            lhs.localPassword == rhs.localPassword &&
            lhs.localPasswordVerified == rhs.localPasswordVerified &&
            lhs.localFolder == rhs.localFolder &&
            lhs.username == rhs.username
        ) {
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: - Functions
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(username)
    }
    
    // MARK: - Private Functions
    
    /// Check the SecureToken status for this user and update it.
    private func updateSecureTokenStatus() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/sysadminctl")
        process.arguments = ["-secureTokenStatus", self.username]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        do {
            try process.run()
        } catch {
            DispatchQueue.main.async {
                self.remotePasswordVerified = false
            }
        }

        DispatchQueue.global(qos: .userInteractive).async {
            process.waitUntilExit()
            do {
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                guard let output = String(data: outputData, encoding: .utf8) else { return }
                
                if output.contains("ENABLED") {
                    DispatchQueue.main.async {
                        self.hasSecureToken = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.hasSecureToken = false
                    }
                }
            }
        }
    }
    
    /**
     Verify the remote password
     - Parameters:
        - password: The password to be checked
        - path: The path as a string that is used for the check
     */
    private func verifyRemotePassword(using password: String, at path: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process.arguments = ["unlock-keychain", "-p", password, path]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        do {
            try process.run()
        } catch {
            DispatchQueue.main.async {
                self.remotePasswordVerified = false
            }
        }

        DispatchQueue.global(qos: .userInteractive).async {
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                let lockProcess = Process()
                lockProcess.executableURL = URL(fileURLWithPath: "/usr/bin/security")
                lockProcess.arguments = ["lock-keychain", path]

                let outputPipe = Pipe()
                lockProcess.standardOutput = outputPipe
                lockProcess.standardError = outputPipe
                do {
                    try lockProcess.run()
                    DispatchQueue.main.async {
                        self.remotePasswordVerified = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.remotePasswordVerified = false
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    self.remotePasswordVerified = false
                }
            }
        }
    }
    
    /**
     Verify the local password
     - Parameters:
        - password: The local password to be checked
     */
    private func verifyLocalPassword(with password: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/dscl")
        process.arguments = ["/Search", "-authonly", self.username, password]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        do {
            try process.run()
        } catch {
            DispatchQueue.main.async {
                self.localPasswordVerified = false
            }
        }

        DispatchQueue.global(qos: .userInteractive).async {
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                DispatchQueue.main.async {
                    self.localPasswordVerified = true
                }
            } else {
                DispatchQueue.main.async {
                    self.localPasswordVerified = false
                }
            }
        }
    }
}
