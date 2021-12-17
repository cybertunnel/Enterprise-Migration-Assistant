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
    
    // MARK: - Constants
    
    /// The different steps that happen during migration
    enum MigrationStep {
        case Welcome, DiskSelection, FolderSelection, Migration, Logoff, InformationVerification, Verification
    }
    // MARK: - Observed Properties
    
    /// The current step that the controller is on
    @Published var currStep: MigrationStep = .Welcome {
        didSet {
            if currStep == .DiskSelection {
                self.logger.info("Migration UI step has been moved to Disk Selection.")
                self.detectedDisks = []
                self.beginDiskDetection()
                self.canProceed = false
            }
            else if currStep == .FolderSelection {
                self.logger.info("Migration UI step has been moved to Folder Selection.")
                if !self.selectedDiskFolders.isEmpty {
                    self.selectedDiskFolders = []
                }
                self.detectPath()
                self.canProceed = false
            }
            else if currStep == .InformationVerification {
                self.logger.info("Migration UI step has been moved to Information Verification.")
                self.user.hasSecureToken =  false
                self.calculateEnoughFree()
                if self.user.remotePasswordVerified {
                    self.canProceed = true
                } else {
                    self.canProceed = false
                }
            }
            else { self.logger.debug("Migration UI step has been moved to \(String(describing: self.currStep.hashValue))")}
        }
    }
    /// Can the controller proceed to the next step
    @Published var canProceed: Bool = true
    
    /// An array of disks detected by the MigrationController
    @Published var detectedDisks: Array <Disk> = []
    
    /// Selected disk from the disk array
    @Published var selectedDisk: Disk? {
        didSet {
            self.logger.info("A disk has been selected.")
            self.logger.debug("Selected disk: \(self.selectedDisk.debugDescription)")
            self.canProceed = true
        }
    }
    
    /// An array of folders from the selected disk
    @Published var selectedDiskFolders: Array <Folder> = []
    
    /// The selected folder
    @Published var selectedUserFolder: Folder? {
        didSet {
            self.logger.info("User folder has been selected.")
            self.logger.debug("Selected folder: \(self.selectedUserFolder.debugDescription)")
            self.canProceed = true
            self.user.remoteFolder = selectedUserFolder
        }
    }
    
    /// The user being migrated
    @Published var user: User
    
    /// Is there enough free space?
    @Published var enoughFreeSpace: Bool = false {
        didSet {
            self.canProceed = enoughFreeSpace
        }
    }
    
    /// This is populated when there is an error that happened
    @Published var error: Error?
    
    /// What size should the final folder be?
    @Published var targetSize = 0
    
    /// What size is it currently?
    @Published var currSize = 0
    
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
        self.user = User.detectUser()
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
                sleep(5)
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
        self.logger.info("Starting the migration process")
        self.canProceed = false
        self.makeMigratorUser()
        self.createLaunchDaemon()
        
        var tempFolder = self.user.localFolder?.urlPath.pathComponents
        let tempFolderName = "migrator-\(tempFolder?.last ?? "")"
        _ = tempFolder?.popLast()
        var new_dest = self.user.localFolder?.urlPath.deletingLastPathComponent()
        new_dest?.appendPathComponent(tempFolderName)
        
        
        guard let srcFolder = self.user.remoteFolder, let dstFolder = new_dest else { return }
        
        self.migrateFolder(from: srcFolder.urlPath, to: dstFolder)
        self.startLaunchDaemon()
        self.canProceed = true
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
                            self.currSize = currSize
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
    
    /**
     Detect the potential user paths for the selected disk
     */
    private func detectPath() {
        logger.info("Attempting to detect user folders on the selected disk.")
        guard let basePath = self.selectedDisk?.pathURL.path else { return }
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
                    var folder_url = URL(fileURLWithPath: self.selectedDisk?.pathURL.path ?? "" + "/Users/" + user_folder)
                    folder_url = folder_url.appendingPathComponent("Users/\(user_folder)")
                    
                    return Folder(name: user_folder, urlPath: folder_url)
                }
                
                DispatchQueue.main.async {
                    self.selectedDiskFolders = user_folder_urls
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
        
        if self.detectedDisks != detectedDisks {
            print("New disk detected!")
            DispatchQueue.main.async {
                self.detectedDisks = detectedDisks
            }
        }
    }
    
    /**
     Make migrator user
     */
    private func makeMigratorUser() {
        self.logger.info("Attempting to make migration user")
        do {
            try ExecutionService.makeMigratorUser(usingAdmin: self.user) { [weak self] result in
                DispatchQueue.main.async {
                    if self != nil {
                        self?.logger.info("Migration user created!")
                    }
                }
            }
        } catch {
            self.error = error
        }
    }
    
    /**
     Create the Launch Daemon
     */
    private func createLaunchDaemon() {
        self.logger.info("Attempting to create launch daemon")
        let currPath = Bundle.main.resourceURL
        let toolPath = currPath?.appendingPathComponent("/Migrator Tool")
        do {
            try ExecutionService.createLaunchDaemon(migratorToolPath: toolPath?.path ?? "", withOldUser: self.user.username, withOldHome: self.user.remoteFolder?.urlPath.path ?? "", withOldPass: self.user.remotePassword, forUser: self.user.username) { [weak self] result in
                switch result {
                case .success(let output):
                    self?.logger.info("Successfully created folder. Output: \(output)")
                case .failure(let error):
                    self?.logger.info("Did not successfully create folder. \(error.localizedDescription)")
                }
            }
        } catch {
            self.error = error
        }
    }
    
    /**
     Start the Launch Daemon
     */
    private func startLaunchDaemon() {
        self.logger.info("Attempting to load the launch daemon")
        do {
            try ExecutionService.startLaunchDaemon { result in
                switch result {
                case .success(let output):
                    self.logger.info("Obtained output of \(output)")
                case .failure(let error):
                    self.logger.error("Obtained an error of \(error.localizedDescription)")
                }
            }
        } catch {
            self.error = error
        }
        
    }
    
    /**
     Migrate from one folder to another
     - Parameters:
        - srcFolder: The folder which is being copied
        - destFolder: The new folder which you want the data to be copied to
     */
    private func migrateFolder(from srcFolder: URL, to destFolder: URL) {
        logger.info("Attempting to copy \(srcFolder.debugDescription) to \(destFolder.debugDescription)")
        do {
            self.targetSize = try self.user.remoteFolder?.urlPath.directoryTotalAllocatedSize(includingSubfolders: true) ?? 0
        } catch {
            self.error = error
        }
        self.monitorDestFolder(for: destFolder)
        do {
            try ExecutionService.moveFolder(from: srcFolder, to: destFolder) { result in
                switch result {
                case .success(let output):
                    self.logger.info("Successfully obtained output of \(output)")
                    DispatchQueue.main.async {
                        self.canProceed = true
                        self.currSize = self.targetSize
                    }
                case .failure(let error):
                    self.logger.error("Obtained an error of \(error.localizedDescription)")
                }
            }
        } catch {
            self.error = error
        }
    }
}
