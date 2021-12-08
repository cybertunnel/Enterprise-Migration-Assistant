//
//  MigrationController.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 11/17/21.
//

import Foundation
import DiskArbitration
import SwiftUI

class MigrationController: ObservableObject {
    
    enum MigrationStep {
        case Welcome, DiskSelection, FolderSelection, Migration, Logoff, InformationVerification
    }
    
    @Published var currStep: MigrationStep = .Welcome {
        didSet {
            if currStep == .DiskSelection {
                self.detectedDisks = []
                self.beginDiskDetection()
                self.canProceed = false
            }
            else if currStep == .FolderSelection {
                if self.selectedDiskFolders != nil {
                    self.selectedDiskFolders = nil
                }
                self.detectPath()
                self.canProceed = false
            }
            else if currStep == .InformationVerification {
                self.user.hasSecureToken =  self.secureTokenStatus(for: self.user.username)
                self.calculateEnoughFree()
                if self.user.remotePasswordVerified {
                    self.canProceed = true
                } else {
                    self.canProceed = false
                }
            }
        }
    }
    @Published var canProceed: Bool = true
    @Published var detectedDisks: Array <Disk> = []
    @Published var selectedDisk: Disk? {
        didSet {
            self.canProceed = true
        }
    }
    @Published var selectedDiskFolders: Array <Folder>?
    @Published var selectedUserFolder: Folder? {
        didSet {
            self.canProceed = true
            self.user.remoteFolder = selectedUserFolder
        }
    }
    
    @Published var user: User = User.detectUser()
    @Published var enoughFreeSpace: Bool = false
    
    private var diskDetectActive: Bool = false
    
    func beginDiskDetection() {
        DispatchQueue(label: "Disk Detection", qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil).async {
            print("Disk detection background process started.")
            self.diskDetectActive = true
            while self.diskDetectActive {
                self.detectDisks()
                sleep(5)
            }
            
        }
    }
    
    func stopDiskDetection() {
        self.diskDetectActive = false
    }
    
    func verifyRemotePassword() {
        self.verifyPassword(using: self.user.remotePassword, at: "")
    }
    
    // MARK: - Private Functions
    
    private func verifyPassword(using password: String, at path: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process.arguments = ["unlock-keychain", "-p", self.user.remotePassword, "\(self.user.remoteFolder?.urlPath.path ?? "")/Library/Keychains/login.keychain-db"]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        do {
            try process.run()
        } catch {
            DispatchQueue.main.async {
                self.user.remotePasswordVerified = false
                self.canProceed = false
            }
        }

        DispatchQueue.global(qos: .userInteractive).async {
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                let lockProcess = Process()
                lockProcess.executableURL = URL(fileURLWithPath: "/usr/bin/security")
                lockProcess.arguments = ["lock-keychain", "\(self.user.remoteFolder?.urlPath.path ?? "")/Library/Keychains/login.keychain-db"]

                let outputPipe = Pipe()
                lockProcess.standardOutput = outputPipe
                lockProcess.standardError = outputPipe
                do {
                    try lockProcess.run()
                    DispatchQueue.main.async {
                        self.objectWillChange.send()
                        self.user.remotePasswordVerified = true
                        self.canProceed = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.user.remotePasswordVerified = false
                        self.canProceed = false
                    }
                }
            }
        }
    }
    
    private func checkSecureTokenStatus() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/sysadminctl")
        process.arguments = ["-secureTokenStatus", self.user.username]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        do {
            try process.run()
        } catch {
            self.user.hasSecureToken = false
        }

        DispatchQueue.global(qos: .userInteractive).async {
            process.waitUntilExit()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()

            guard let output = String(data: outputData, encoding: .utf8) else {
                self.user.hasSecureToken = false
                return
            }

            if output.contains("ENABLED") { self.user.hasSecureToken = true }
            else { self.user.hasSecureToken = false }
        }
    }
    
    private func calculateEnoughFree() {
        do {
            let result = try FileManager.default.attributesOfFileSystem(forPath: "/")
            guard let free = result[.systemFreeSize] as? Int else {
                DispatchQueue.main.async {
                    self.enoughFreeSpace = false
                }
                return
            }
            
            guard let used = self.user.remoteFolder?.sizeOnDisk else {
                DispatchQueue.main.async {
                    self.enoughFreeSpace = false
                }
                return
            }
            if used <  free {
                DispatchQueue.main.async {
                    self.enoughFreeSpace = true
                }
            }
        } catch {
            print("Error occurred")
        }
    }
    
    private func detectPath() {
        guard let basePath = self.selectedDisk?.pathURL.path else { return }
        let path = basePath + "/Users/"
        do {
            let folders = try FileManager.default.contentsOfDirectory(atPath: path)
            let user_folders = folders.filter { folder in
                if folder == ".localized" || folder == "Shared" || folder == ".DS_Store"{
                    return false
                }
                else {
                    return true
                }
            }
            DispatchQueue(label: "Folder Detection", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem).async {
                var user_folder_urls: Array <Folder> = []
                user_folder_urls = user_folders.map { user_folder in
                    var folder_url = URL(fileURLWithPath: self.selectedDisk?.pathURL.path ?? "" + "/Users/" + user_folder)
                    folder_url = folder_url.appendingPathComponent("Users/\(user_folder)")
                    
                    return Folder(name: user_folder, urlPath: folder_url)
                }
                
                DispatchQueue.main.async {
                    self.selectedDiskFolders = user_folder_urls
                }
            }
            
        } catch {
            print("ERROR processing folder lookup")
        }
    }
    
    private func detectDisks() {
        let disks = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeURLKey], options: .skipHiddenVolumes)
        var detectedDisks: Array <Disk> = []
        
        disks?.forEach { disk in
            do {
                let diskObj = try Disk.fromURL(disk)
                detectedDisks.append(diskObj)
            }
            catch DiskError.NotValidDeviceType(let type) {
                print("Unsupported type found: \(type)")
            }
            catch DiskError.UnableToGetDescription {
                print("Unable to get description")
            }
            catch {
                print("Unknown error occurred")
            }
        }
        
        if self.detectedDisks != detectedDisks {
            print("New disk detected!")
            DispatchQueue.main.async {
                self.detectedDisks = detectedDisks
            }
        }
    }
    
    private func secureTokenStatus(for user: String) -> Bool {
        return false
    }
}
