//
//  HelperExecutionService.swift
//  com.github.cybertunnel.Enterprise-Migration-Assistant.helper
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation
import OSLog

class HelperExecutionService {
    
    typealias Handler = (Result<String, Error>) -> Void
    static let logger = Logger(subsystem: AppConstants.bundleIdentifier, category: "Helper Execution Service")
    
    static func copyFolder(from srcFolder: URL, to dstFolder: URL, then completion: @escaping Handler) {
        if FileManager.default.fileExists(atPath: dstFolder.path) {
            logger.error("File \(dstFolder.path.debugDescription) already exists.")
            completion(.failure(MigrationError.fileAlreadyExists))
        } else {
            if FileManager.default.fileExists(atPath: srcFolder.path) {
                logger.debug("File/folder at \(srcFolder.path.debugDescription) is confirmed to exist, proceeding.")
                do {
                    try FileManager.default.copyItem(at: srcFolder, to: dstFolder)
                    completion(.success("Successfully copied \(srcFolder.path.debugDescription) to \(dstFolder.path.debugDescription)"))
                } catch {
                    logger.error("Error occurred while attempting to copy folder contents over. Error: \(error.localizedDescription, privacy: .public)")
                    completion(.failure(error))
                }
            } else {
                logger.error("Source file/folder at \(srcFolder.path.debugDescription, privacy: .public) does not exist.")
                completion(.failure(MigrationError.fileDoesNotExist))
            }
        }
    }
    
    static func createLaunchDaemon(migratorToolPath path: String, withOldUser oldUser: String, withOldHome oldHome: String, withOldPass oldPass: String, forUser user: String, then completion: @escaping Handler) {
        let filePath = URL(fileURLWithPath: "/Library/LaunchDaemons/com.github.cybertunnel.Enterprise-Migration-Assistant.migratorTool.plist")
        let contents = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.github.cybertunnel.Enterprise-Migration-Assistant.migratorTool</string>
            <key>ProgramArguments</key>
            <array>
                <string>\(path)</string>
                <string>\(oldUser)</string>
                <string>\(oldHome)</string>
                <string>\(oldPass)</string>
                <string>\(user)</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
        </dict>
        </plist>
        """
        
        if FileManager.default.createFile(atPath: filePath.path, contents: contents.data(using: .utf8)) {
            completion(.success("Successfully created LaunchDaemon!"))
            return
        }
        else {
            completion(.failure(MigrationError.invalidPermission))
            return
        }
    }
    
    static func makeMigratorUser(username: String, withName name: String, withPassword password: String, usingAdmin adminUser: String, withAdminPass adminPass: String, then completion: @escaping Handler) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/sysadminctl")
        process.arguments = ["-addUser", username, "-fullName", name, "-password", password, "-admin", "-adminUser", adminUser, "-adminPassword", adminPass]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        try process.run()

        DispatchQueue.global(qos: .userInteractive).async {
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                completion(.success("Migration user created successfully."))
            } else {
                DispatchQueue.main.async {
                    completion(.failure(MigrationError.invalidPermission))
                    return
                }
            }
        }
    }
}
