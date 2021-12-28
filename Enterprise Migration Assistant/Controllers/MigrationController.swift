//
//  MigrationController.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 11/17/21.
//

import Foundation
import DiskArbitration
import SwiftUI
import OSLog

/**
 A Controller that handles everything around the migration.
 */
class MigrationController: ObservableObject {
    
    // MARK: - Class Structs
    struct MigrationInformation {
        var detectedDisks: Array <Disk> = []
        var detectedFolders: Array <Folder> = []
        
        var selectedDisk: Disk?
        var selectedFolder: Folder?
        
        var user: User
        
        var enoughFreeSpace: Bool = false
        
        var targetFolderSize: Int = 0
        var currFolderSize: Int = 0
    }
    
    // MARK: - Constants
    
    /// The different steps that happen during migration
    enum MigrationStep {
        case Welcome, DiskSelection, FolderSelection, Migration, InputRequest, Verification, Logoff
    }
    
    
    // MARK: - Observed Properties
    
    /// The current step that the controller is on
    @Published var currStep: MigrationStep = .Welcome {
        didSet {
            switch self.currStep {
            
            case .DiskSelection:
                self.logger.info("Migration UI step has been moved to Disk Selection.")
                self.detailInformation.detectedDisks = []
                self.beginDiskDetection()
                self.canProceed = false
            
            case .FolderSelection:
                self.logger.info("Migration UI step has been moved to Folder Selection.")
                if !self.detailInformation.detectedFolders.isEmpty { self.detailInformation.detectedFolders = [] }
                self.detectPath()
                self.canProceed = false
            
            case .InputRequest:
                self.logger.info("Migration UI step has been moved to Input Request.")
                self.canProceed = false
                
            case .Verification:
                self.logger.info("Migration UI step has been moved to Verification.")
                self.detailInformation.user.hasSecureToken = false
                self.calculateEnoughFree()
                if self.detailInformation.user.remotePasswordVerified { self.canProceed = true }
                else { self.canProceed = false }
            
            case .Migration:
                self.logger.info("Migration UI step has been moved to Migration.")
                self.canProceed = false
            
            case .Logoff:
                self.logger.info("Migration UI step has been moved to Logoff.")
            
            case .Welcome:
                self.logger.info("Migration UI step has been moved to Welcome.")
                self.canProceed = true
            
            }
        }
    }
    /// Can the controller proceed to the next step
    @Published var canProceed: Bool = true
    
    @Published var detailInformation: MigrationInformation {
        didSet {
            if self.currStep == .DiskSelection && self.detailInformation.selectedDisk != nil {
                self.canProceed = true
            }
            
            if self.currStep == .FolderSelection && self.detailInformation.selectedFolder != nil {
                self.canProceed = true
            }
        }
    }
    
    /// This is populated when there is an error that happened
    @Published var error: Error?
    
    /// Is the application in testing mode
    @Published var testingMode: Bool = true {
        didSet {
            print("Set to \(testingMode.description)")
        }
    }
    
    
    // MARK: - Private Properties
    
    /// Is the destination folder being monitored
    private var monitorDestFolder: Bool = false
    
    /// Is the disk detection module active
    private var diskDetectActive: Bool = false
    
    /// The log variable
    private let logger = Logger(subsystem: AppConstants.bundleIdentifier, category: "Migration Controller")
    
    
    // MARK: - Initialiser
    init() {
        logger.info("Migration controller initialized.")
        self.detailInformation = MigrationInformation(user: User.detectUser())
    }
    
    
    // MARK: - Functions
    
    /**
     Begin the background disk detection
     */
    func beginDiskDetection() {
        
        DispatchQueue(label: "Disk Detection", qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil).async {
            self.logger.info("Disk detection has started.")
            self.diskDetectActive = true
            while self.diskDetectActive {
                self.logger.info("Attempting to detect disks")
                self.detectDisks()
                sleep(1)
            }
        }
    }
    
    /**
     Stop the background disk detection
     */
    func stopDiskDetection() {
        self.logger.info("Stopping disk detection.")
        self.diskDetectActive = false
    }
    
    /**
     Start the migration process
     */
    func startMigration() {
        Task.init {
            do {
                self.logger.info("Starting the migration process")
                self.canProceed = false
                await self.makeMigratorUser()
                if !self.testingMode { try await self.createLaunchDaemon() }
                
                var tempFolder = self.detailInformation.user.localFolder?.urlPath.pathComponents
                let tempFolderName = "migrator-\(tempFolder?.last ?? "")"
                _ = tempFolder?.popLast()
                var new_dest = self.detailInformation.user.localFolder?.urlPath.deletingLastPathComponent()
                new_dest?.appendPathComponent(tempFolderName)
                
                guard let srcFolder = self.detailInformation.user.remoteFolder, let dstFolder = new_dest else { return }
                
                try await self.migrateFolder(from: srcFolder.urlPath, to: dstFolder)
                if !self.testingMode {  try await self.startLaunchDaemon() }
                self.canProceed = true
            } catch {
                self.error = error
            }
        }
    }
    
    
    // MARK: - Private Functions
    
    /**
     Monitor provided folder
     - Parameter path: (URL) The directory being monitored.
     */
    private func monitorDestFolder(for path: URL) {
        self.monitorDestFolder = true
        DispatchQueue(label: "Progress Monitoring", qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil).async {
            while self.monitorDestFolder {
                do {
                    if let currSize = try path.directoryTotalAllocatedSize(includingSubfolders: true) {
                        DispatchQueue.main.async {
                            self.detailInformation.currFolderSize = currSize
                        }
                    }
                } catch {
                    
                }
                sleep(5)
            }
        }
    }
    
    /**
     Calculate if there is enough free space on the disk
     */
    private func calculateEnoughFree() {
        do {
            let result = try FileManager.default.attributesOfFileSystem(forPath: "/")
            guard let free = result[.systemFreeSize] as? Int else {
                DispatchQueue.main.async {
                    self.detailInformation.enoughFreeSpace = false
                }
                return
            }
            
            guard let used = self.detailInformation.user.remoteFolder?.sizeOnDisk else {
                DispatchQueue.main.async {
                    self.detailInformation.enoughFreeSpace = false
                }
                return
            }
            
            if used <  free {
                DispatchQueue.main.async {
                    self.detailInformation.enoughFreeSpace = true
                }
            }
        } catch {
            self.logger.error("Obtained an error while attempting to calculate if there was enough free space. \(error.localizedDescription)")
        }
    }
    
    /**
     Detect the potential user paths for the selected disk
     */
    private func detectPath() {
        logger.info("Attempting to detect user folders on the selected disk.")
        guard let basePath = self.detailInformation.selectedDisk?.pathURL.path else { return }
        let path = basePath + "/Users/"
        do {
            let folders = try FileManager.default.contentsOfDirectory(atPath: path)
            logger.debug("Detected folders: \(folders.debugDescription)")
            let user_folders = folders.filter { folder in
                if folder == ".localized" || folder == "Shared" || folder == ".DS_Store"{
                    return false
                }
                else {
                    return true
                }
            }
            logger.debug("Total number of user folders: \(user_folders.count)")
            logger.debug("Found folders: \(user_folders.debugDescription)")
            DispatchQueue(label: "Folder Detection", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem).async {
                self.logger.debug("Creating folder objects for the folders")
                var user_folder_urls: Array <Folder> = []
                user_folder_urls = user_folders.map { user_folder in
                    var folder_url = URL(fileURLWithPath: self.detailInformation.selectedDisk?.pathURL.path ?? "" + "/Users/" + user_folder)
                    folder_url = folder_url.appendingPathComponent("Users/\(user_folder)")
                    
                    return Folder(name: user_folder, urlPath: folder_url)
                }
                
                DispatchQueue.main.async {
                    self.detailInformation.detectedFolders = user_folder_urls
                }
            }
            
        } catch {
            self.error = MigrationError.noUserFoldersDetected
        }
    }
    
    /**
     Detect mounted disks
     */
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
        
        if self.detailInformation.detectedDisks != detectedDisks {
            print("New disk detected!")
            DispatchQueue.main.async {
                self.detailInformation.detectedDisks = detectedDisks
            }
        }
    }
    
    /**
     Make migrator user
     */
    private func makeMigratorUser() async {
        self.logger.info("Attempting to make migration user")
        do {
            try await ExecutionService.makeMigratorUser(usingAdmin: self.detailInformation.user)
            self.logger.info("Migration user created!")
        } catch {
            self.error = error
        }
    }
    
    /**
     Create the Launch Daemon
     */
    private func createLaunchDaemon() async throws {
        self.logger.info("Attempting to create launch daemon")
        let currPath = Bundle.main.resourceURL
        let toolPath = currPath?.appendingPathComponent("/Migrator Tool")
        try await ExecutionService.createLaunchDaemon(migratorToolPath: toolPath?.path ?? "", withOldUser: self.detailInformation.user.username, withOldHome: self.detailInformation.user.remoteFolder?.urlPath.path ?? "", withOldPass: self.detailInformation.user.remotePassword, forUser: self.detailInformation.user.username)
    }
    
    /**
     Start the Launch Daemon
     */
    private func startLaunchDaemon() async throws {
        self.logger.info("Attempting to load the launch daemon")
        try await ExecutionService.startLaunchDaemon()
    }
    
    /**
     Migrate from one folder to another
     - Parameters:
        - srcFolder: The folder which is being copied
        - destFolder: The new folder which you want the data to be copied to
     */
    private func migrateFolder(from srcFolder: URL, to destFolder: URL) async throws {
        logger.info("Attempting to copy \(srcFolder.debugDescription) to \(destFolder.debugDescription)")
        
        self.detailInformation.targetFolderSize = try self.detailInformation.user.remoteFolder?.urlPath.directoryTotalAllocatedSize(includingSubfolders: true) ?? 0
        self.monitorDestFolder(for: destFolder)
        let _ = try await ExecutionService.moveFolder(from: srcFolder, to: destFolder)
        self.canProceed = true
        self.detailInformation.currFolderSize = self.detailInformation.targetFolderSize
    }
}
