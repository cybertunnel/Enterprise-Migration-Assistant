//
//  HelperProtocol.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation

@objc(HelperProtocol)
public protocol HelperProtocol {
    @objc func copyFolder(from src: URL, to dest: URL) async throws -> Void
    @objc func startLaunchDaemon() async throws -> Void
    @objc func createMigrationUser(username: String, withName name: String, withPassword password: String, usingAdmin adminUser: String, withAdminPass adminPass: String) async throws -> Void
    @objc func createLaunchDaemon(migratorToolPath path: String, withOldUser oldUser: String, withOldHome oldHome: String, withOldPass oldPass: String, forUser user: String) async throws -> Void
}
