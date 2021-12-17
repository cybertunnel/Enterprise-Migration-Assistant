//
//  AppleEvent.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/16/21.
//

import Foundation
import OSLog
import ApplicationServices

/**
 Helps send Apple Events
 */
class SendAppleEvent {
    
    static let logger = Logger(subsystem: AppConstants.bundleIdentifier, category: "Apple Event")
    
    static func sleep() throws {
        self.logger.info("Attempting to put system to sleep.")
        try self.sendEvent(eventCode: kAESleep)
    }
    
    static func shutdown() throws {
        self.logger.info("Attempting to put system to shutdown.")
        try self.sendEvent(eventCode: kAEShutDown)
    }
    
    static func logout() throws {
        self.logger.info("Attempting to put system to logout.")
        try self.sendEvent(eventCode: kAELogOut)
    }
    
    static func restart() throws {
        self.logger.info("Attempting to put system to restart.")
        try self.sendEvent(eventCode: kAERestart)
    }
    
    static private func sendEvent(eventCode: OSType) throws {
        // https://developer.apple.com/library/content/qa/qa1134/_index.html
        // https://stackoverflow.com/questions/37783016/sending-appleevent-fails-with-sandbox
        /*
         * You must have the following exeptions in your .entitlements file:
         *
         *  <key>com.apple.security.temporary-exception.apple-events</key>
         *  <array>
         *      <string>com.apple.loginwindow</string>
         *  </array>
         *
         */
        
        var kPSNOfSystemProcess = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kSystemProcess))
        var targetDesc = AEAddressDesc()
        var status = OSStatus()
        var error = OSErr()

        error = AECreateDesc(keyProcessSerialNumber, &kPSNOfSystemProcess, MemoryLayout<ProcessSerialNumber>.size, &targetDesc)

        if error != noErr {
            self.logger.error("Error creating Desc \(error.description)")
            throw NSError(domain: "AECreateDesc", code: Int(error), userInfo: nil)
        }

        var event = AppleEvent()
        error = AECreateAppleEvent(kCoreEventClass,
                                   eventCode,
                                   &targetDesc,
                                   AEReturnID(kAutoGenerateReturnID),
                                   AETransactionID(kAnyTransactionID),
                                   &event)

        if error != noErr {
            self.logger.error("Error creatign AppleEvent, \(error.description)")
            throw NSError(domain: "AECreateAppleEvent", code: Int(error), userInfo: nil)
        }

        AEDisposeDesc(&targetDesc)

        var reply = AppleEvent()

        status = AESendMessage(&event,
                               &reply,
                               AESendMode(kAENoReply),
                               1000)

        if status != OSStatus(0) {
            self.logger.error("Error sending AppleEvent, \(error.description)")
            throw NSError(domain: "AESendMessage", code: Int(status), userInfo: nil)
        }

        AEDisposeDesc(&event)
        AEDisposeDesc(&reply)
    }
}
