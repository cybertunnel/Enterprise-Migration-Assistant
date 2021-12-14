//
//  ToolExecutionService.swift
//  Migrator Tool
//
//  Created by Morgan, Tyler on 12/13/21.
//

import Foundation

class ToolExecutionService {
    
    enum ExecutionError: Error {
        case permissionUpdateFailed, ownerUpdateFailed, userDeletionFailed, userCreationFailed
    }
    
    static func create(user username: String, withPassword password: String, migratorUser: String, migratorPassword: String, then completion: @escaping (String?, Error?) -> Void) throws {
        //sysadminctl -addUser $username -fullName "$username" -password "$password" -home "/Users/$username" -admin -adminUser "migrator" -adminPassword "$migratorUserPassword" > $log 2>&1 || exit 6
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/sysadminctl")
        process.arguments = ["-addUser", username, "-fullName", username, "-password", password, "-home", "/Users/\(username)", "-admin", "-adminUser", migratorUser, "-adminPassword", migratorPassword]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        try process.run()

        DispatchQueue.global(qos: .userInteractive).async {
            process.waitUntilExit()
        }
    }
    
    static func createHidden(user username: String, then completion: @escaping (String?, Error?) -> Void) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/dscl")
        process.arguments = [".", "create", "/Users/\(username)", "IsHidden", "1"]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        try process.run()

        DispatchQueue.global(qos: .userInteractive).async {
            process.waitUntilExit()
            if process.terminationStatus == 0 {
               completion("Successfully created \(username)", nil)
            } else {
                completion(nil, ExecutionError.userCreationFailed)
            }
        }
    }
    
    static func moveFiles(from src: String, to dst: String, then completion: @escaping (String?, Error?) -> Void) {
        do {
            try FileManager.default.moveItem(atPath: src, toPath: dst)
            completion("Successfully moved files.", nil)
        } catch {
            completion(nil, error)
        }
    }
    
    static func delete(user username: String, then completion: @escaping (String?, Error?) -> Void) throws {
        // TODO: Add check for user conflict
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/sysadminctl")
        process.arguments = ["-deleteUser", username, "-adminUser", "migrator", "-adminPassword", "migrationisfun"]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        try process.run()

        DispatchQueue.global(qos: .userInteractive).async {
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                completion("Successfully deleted the old user", nil)
            } else {
                completion(nil, ExecutionError.userDeletionFailed)
            }
        }
    }
    
    static func updateOwner(to user: String,for path: String, then completion: @escaping (String?, Error?) -> Void) throws {
        // chown -R "$username":staff "/Users/$username" > $log 2>&1 # allowing non-zero exit code, certain library items fail but don't seem to matter
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/chown")
        process.arguments = ["-R", "\(user):staff", path]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        try process.run()

        DispatchQueue.global(qos: .userInteractive).async {
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                completion("Successfully changed owners.", nil)
            } else {
                completion(nil, ExecutionError.ownerUpdateFailed)
            }
        }
    }
    
    static func unloadLaunchDaemon(completion: @escaping (String?, Error?) -> Void) throws {
        
    }
    
    static func removePriviledgedHelper(at path: URL, completion: @escaping (String?, Error?) -> Void) throws {
        
    }
    
    static func removeLaunchDaemon(at path: URL, completion: @escaping (String?, Error?) -> Void) throws {
        
    }
    
    static func fixPermissions(for user: String, then completion: @escaping (String?, Error?) -> Void) throws {
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/chmod")
        process.arguments = ["-R", "-N", "/Users/\(user)"]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        try process.run()

        DispatchQueue.global(qos: .userInteractive).async {
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/chflags")
                process.arguments = ["-R", "nouchg", "/Users/\(user)"]

                let outputPipe = Pipe()
                process.standardOutput = outputPipe
                process.standardError = outputPipe
                do {
                    try process.run()
                } catch {
                    completion(nil, error)
                }

                DispatchQueue.global(qos: .userInteractive).async {
                    process.waitUntilExit()
                    
                    if process.terminationStatus == 0 {
                        completion("Successfully update permissions", nil)
                    } else {
                        completion(nil, ExecutionError.permissionUpdateFailed)
                    }
                }
            } else {
                completion(nil, ExecutionError.permissionUpdateFailed)
            }
        }
    }
}
