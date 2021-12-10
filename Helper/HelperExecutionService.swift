//
//  HelperExecutionService.swift
//  com.github.cybertunnel.Enterprise-Migration-Assistant.helper
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation

class HelperExecutionService {
    
    typealias Handler = (Result<String, Error>) -> Void
    
    static func createLaunchDaemon(migratorToolPath path: String, withOldUser oldUser: String, withOldHome oldHome: String, withOldPass oldPass: String, forUser user: String, then completion: @escaping Handler) {
        completion(.success("Testing"))
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
