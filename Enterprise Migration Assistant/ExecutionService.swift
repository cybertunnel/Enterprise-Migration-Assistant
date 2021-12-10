//
//  ExecutionService.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation

struct ExecutionService {
    
    // MARK: - Constants
    
    typealias Handler = (Result<String, Error>) -> Void
    
    static func makeMigratorUser(_ username: String = "migrator", withName name: String = "Please Wait...", withPassword password: String = "migrationisfun", usingAdmin admin: User, then completion: @escaping Handler) throws {
        let remote = try HelperRemote().getRemote()
        
        remote.createMigrationUser(username: username, withName: name, withPassword: password, usingAdmin: admin.username, withAdminPass: admin.localPassword) { (output, error) in
            completion(Result(string: output, error: error))
        }
        
    }
}
