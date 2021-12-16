//
//  HelperProtocol.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation

@objc(HelperProtocol)
public protocol HelperProtocol {
    @objc func copyFolder(from src: URL, to dest: URL, then completion: @escaping (String?, Error?) -> Void)
    @objc func startLaunchDaemon(then completion: @escaping (String?, Error?) -> Void)
    @objc func createMigrationUser(username: String, withName name: String, withPassword password: String, usingAdmin adminUser: String, withAdminPass adminPass: String, then completion: @escaping (String?, Error?) -> Void)
    @objc func createLaunchDaemon(migratorToolPath path: String, withOldUser oldUser: String, withOldHome oldHome: String, withOldPass oldPass: String, forUser user: String, then completion: @escaping (String?, Error?) -> Void)
}
