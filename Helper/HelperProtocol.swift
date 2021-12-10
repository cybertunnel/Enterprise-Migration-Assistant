//
//  HelperProtocol.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation

@objc(HelperProtocol)
public protocol HelperProtocol {
    @objc func copyFolder(from src: URL, to dest: URL, then completion: @escaping (String?, Error) -> Void)
    @objc func createLaunchDaemon()
    @objc func startLaunchDaemon()
    @objc func createMigrationUser(username: String, withName name: String, withPassword password: String, usingAdmin adminUser: String, withAdminPass adminPass: String, then completion: @escaping (String?, Error?) -> Void)
}
