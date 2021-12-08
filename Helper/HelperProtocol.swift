//
//  HelperProtocol.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation

@objc(HelperProtocol)
public protocol HelperProtocol {
    @objc func verifyRemoteKeychainPassword()
    @objc func verifyLocalKeychainPassword()
    @objc func copyFolder(from src: URL, to dest: URL, then completion: @escaping (String?, Error) -> Void)
}
