//
//  Helper.swift
//  com.github.cybertunnel.Enterprise-Migration-Assistant.helper
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation

class Helper: NSObject, NSXPCListenerDelegate, HelperProtocol {
    func verifyRemoteKeychainPassword() {
        print("Verified")
    }
    
    func verifyLocalKeychainPassword() {
        print("Verified")
    }
    
    func copyFolder(from src: URL, to dest: URL, then completion: @escaping (String?, Error) -> Void) {
        print("Copied")
    }
    
    
    //  MARK: - Properties
    
    let listener: NSXPCListener
    
    // MARK: - Initialisation
    
    override init() {
        self.listener = NSXPCListener(machServiceName: HelperConstants.domain)
        super.init()
        self.listener.delegate = self
    }
    
    // MARK: - Functions // MARK: HelperProtocol
    
    // TODO: Add proper functions
    
    func run() {
        //  Start listening on new connections
        self.listener.resume()
        // prevent the terminal application from exiting
        RunLoop.current.run()
    }
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        newConnection.remoteObjectInterface = NSXPCInterface(with: RemoteApplicationProtocol.self)
        newConnection.exportedObject = self

        newConnection.resume()

        return true
    }
}
