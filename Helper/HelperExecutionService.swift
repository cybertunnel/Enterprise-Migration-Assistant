//
//  HelperExecutionService.swift
//  com.github.cybertunnel.Enterprise-Migration-Assistant.helper
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation

class HelperExecutionService {
    
    typealias Handler = (Result<String, Error>) -> Void
    
    
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
