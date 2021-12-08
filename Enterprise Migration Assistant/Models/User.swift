//
//  User.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 11/18/21.
//

import Foundation
import AppKit

class User: ObservableObject {
    
    let username: String
    @Published var localFolder: Folder?
    @Published var remoteFolder: Folder?
    @Published var remotePassword: String = "" {
        didSet {
            self.verifyPassword(using: remotePassword, at: "")
        }
    }
    @Published var remotePasswordVerified: Bool = false
    @Published var localPassword: String = ""
    @Published var localPasswordVerified: Bool = false
    @Published var hasSecureToken: Bool = false
    
    init(_ username: String) {
        self.username = username
    }
    
    static func detectUser() -> User {
        let currUserHomeDir = FileManager.default.homeDirectoryForCurrentUser
        guard let currUser = currUserHomeDir.path.split(separator: "/").last else { return User("")}
        return User(String(describing: currUser))
    }
    
    private func verifyPassword(using password: String, at path: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process.arguments = ["unlock-keychain", "-p", self.remotePassword, "\(self.remoteFolder?.urlPath.path ?? "")/Library/Keychains/login.keychain-db"]

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
                lockProcess.arguments = ["lock-keychain", "\(self.remoteFolder?.urlPath.path ?? "")/Library/Keychains/login.keychain-db"]

                let outputPipe = Pipe()
                lockProcess.standardOutput = outputPipe
                lockProcess.standardError = outputPipe
                do {
                    try lockProcess.run()
                    self.objectWillChange.send()
                    self.remotePasswordVerified = true
                } catch {
                    DispatchQueue.main.async {
                        self.remotePasswordVerified = false
                    }
                }
            }
            else {
                self.remotePasswordVerified = false
            }
        }
    }
}
/**
 
class User: Hashable {
    let username: String
    var localFolder: String?
    var remoteFolder: Folder?
    var remotePassword: String = ""
    var remotePasswordVerified: Bool = false
    var localPassword: String = ""
    var localPasswordVerified: Bool = false
    var hasSecureToken: Bool = false
    
    init(username: String) {
        self.username = username
        
        self.checkSecureTokenStatus()
    }
    
    func verifyRemotePassword() {
        self.verifyPassword(using: self.remotePassword, at: "")
    }
    
    static func detectUser() -> User {
        let currUserHomeDir = FileManager.default.homeDirectoryForCurrentUser
        guard let currUser = currUserHomeDir.path.split(separator: "/").last else { return User(username: "")}
        return User(username: String(describing: currUser))
    }
    
    /**
     local keychain="$oldUserHome/Library/Keychains/login.keychain-db"
         writelog "Checking password against old keychain ("$keychain")"
         security unlock-keychain -p "$userPassword" "$keychain" 2>&1 > $log
         local returnCode=$?
         [[ $returnCode == 0 ]] && security lock-keychain "$keychain"
         return $returnCode
     */
    private func verifyPassword(using password: String, at path: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process.arguments = ["unlock-keychain", "-p", self.remotePassword, "\(self.remoteFolder?.urlPath.path ?? "")/Library/Keychains/login.keychain-db"]

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
                lockProcess.arguments = ["lock-keychain", "\(self.remoteFolder?.urlPath.path ?? "")/Library/Keychains/login.keychain-db"]

                let outputPipe = Pipe()
                lockProcess.standardOutput = outputPipe
                lockProcess.standardError = outputPipe
                do {
                    try lockProcess.run()
                    DispatchQueue.main.async {
                        self.objectWillChange.send()
                        self.remotePasswordVerified = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.remotePasswordVerified = false
                    }
                }
            }
        }
    }
    
    private func checkSecureTokenStatus() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/sysadminctl")
        process.arguments = ["-secureTokenStatus", self.username]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        do {
            try process.run()
        } catch {
            self.hasSecureToken = false
        }

        DispatchQueue.global(qos: .userInteractive).async {
            process.waitUntilExit()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()

            guard let output = String(data: outputData, encoding: .utf8) else {
                self.hasSecureToken = false
                return
            }

            if output.contains("ENABLED") { self.hasSecureToken = true }
            else { self.hasSecureToken = false }
        }
    }
}
*/