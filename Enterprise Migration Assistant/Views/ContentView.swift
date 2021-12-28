//
//  ContentView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 11/17/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var migrationController: MigrationController
    @ObservedObject var user: User
    var body: some View {
        VStack {
            
            if let error = self.migrationController.error {
                Text(error.localizedDescription)
                    .font(.title2)
                    .padding()
                    .foregroundColor(Color.white)
                    .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.red/*@END_MENU_TOKEN@*/)
                    
            }
            if self.migrationController.currStep == .Welcome {
                WelcomeView()
                Spacer()
            }
            else if self.migrationController.currStep == .DiskSelection {
                DiskSelectionView()
                    .environmentObject(self.migrationController)
            }
            else if self.migrationController.currStep == .FolderSelection {
                FolderSelectionView()
                    .environmentObject(self.migrationController)
            }
            else if self.migrationController.currStep == .Migration {
                MigrationView()
                    .environmentObject(self.migrationController)
            }
            else if self.migrationController.currStep == .InputRequest {
                InputRequestView(user: self.$migrationController.detailInformation.user)
                    .environmentObject(self.migrationController.detailInformation.user)
            }
            else if self.migrationController.currStep == .Verification {
                VerificationView()
                    .environmentObject(self.migrationController)
            }
            else if self.migrationController.currStep == .Logoff {
                CompleteView()
            }
            else {
            }
            
            HStack {
                Spacer()
                if self.migrationController.currStep == .Welcome {
                    Button("Quit") {
                        NSApp.terminate(self)
                    }
                }
                else if self.migrationController.currStep != .Logoff {
                    Button("Back") {
                        // Clear out any existing errors
                        self.migrationController.error = nil
                        
                        switch self.migrationController.currStep {
                        case .FolderSelection:
                            self.migrationController.currStep = .DiskSelection
                        case .DiskSelection:
                            self.migrationController.currStep = .Welcome
                        case .InputRequest:
                            self.migrationController.currStep = .FolderSelection
                        case .Verification:
                            self.migrationController.currStep = .InputRequest
                        default:
                            print("Error")
                        }
                    }
                    // TODO: Add logic for when migration occurs
                    .disabled(false)
                }
                
                if self.migrationController.currStep != .Logoff {
                    Button("Continue") {
                        // Clear out any existing errors
                        self.migrationController.error = nil
                        
                        switch self.migrationController.currStep {
                        case .Welcome:
                            self.migrationController.currStep = .DiskSelection
                        case .DiskSelection:
                            self.migrationController.stopDiskDetection()
                            self.migrationController.currStep = .FolderSelection
                        case .FolderSelection:
                            self.migrationController.currStep = .InputRequest
                        case .InputRequest:
                            self.migrationController.currStep = .Verification
                        case .Verification:
                            self.migrationController.startMigration()
                            self.migrationController.currStep = .Migration
                        case .Migration:
                            self.migrationController.currStep = .Logoff
                        default:
                            print("Error")
                        }
                    }
                    .disabled(!self.migrationController.canProceed && !(self.user.remotePasswordVerified && self.user.localPasswordVerified && self.migrationController.currStep == .InputRequest))
                } else {
                    Button("Logoff") {
                        try! SendAppleEvent.logout()
                    }
                }
            }
            .padding()
        }
        .overlay(TestingView(testingMode: self.migrationController.testingMode), alignment: .topTrailing)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(user: User("Example 1"))
            .frame(width: 800, height: 600)
            .environmentObject({ () -> MigrationController in
                let controller = MigrationController()
                controller.error = MigrationError.invalidPermission
                return controller
            }())
        ContentView(user: User("Example 1"))
            .frame(width: 800, height: 600)
            .environmentObject(MigrationController())
        
        ContentView(user: User("Example 1"))
            .frame(width: 800, height: 600)
            .environmentObject({ () -> MigrationController in
                let controller = MigrationController()
                controller.currStep = .DiskSelection
                controller.stopDiskDetection()
                let disks = [
                    Disk(name: "Example 1", volumeType: "APFS", pathURL: URL(fileURLWithPath: "/Volumes/Example 1"), capacity: 250000, free: 20000, used: 20000, isEncrypted: true),
                    Disk(name: "Example 2", volumeType: "APFS", pathURL: URL(fileURLWithPath: "/Volumes/Example 1"), capacity: 250000, free: 20000, used: 20000, isEncrypted: true)
                ]
                controller.detailInformation.detectedDisks = disks
                controller.detailInformation.selectedDisk = disks.first
                return controller
            }())
        
        ContentView(user: User("Example 1"))
            .frame(width: 800, height: 600)
            .environmentObject({ () -> MigrationController in
                let controller = MigrationController()
                controller.currStep = .FolderSelection
                controller.stopDiskDetection()
                let disks = [
                    Disk(name: "Example 1", volumeType: "APFS", pathURL: URL(fileURLWithPath: "/Volumes/Example 1"), capacity: 250000, free: 20000, used: 20000, isEncrypted: true),
                    Disk(name: "Example 2", volumeType: "APFS", pathURL: URL(fileURLWithPath: "/Volumes/Example 1"), capacity: 250000, free: 20000, used: 20000, isEncrypted: true)
                ]
                let folders = [
                    Folder(name: "Example 1", urlPath: URL(fileURLWithPath: "/Users/Example 1"), size: 1500000),
                    Folder(name: "Example 2", urlPath: URL(fileURLWithPath: "/Users/Example 1"), size: 1500000)
                ]
                controller.detailInformation.detectedDisks = disks
                controller.detailInformation.selectedDisk = disks.first
                controller.detailInformation.detectedFolders = folders
                controller.detailInformation.selectedFolder = folders.first
                return controller
            }())
        
        ContentView(user: User("Example 1"))
            .frame(width: 800, height: 600)
            .environmentObject({ () -> MigrationController in
                let controller = MigrationController()
                controller.currStep = .InputRequest
                controller.stopDiskDetection()
                let disks = [
                    Disk(name: "Example 1", volumeType: "APFS", pathURL: URL(fileURLWithPath: "/Volumes/Example 1"), capacity: 250000, free: 20000, used: 20000, isEncrypted: true),
                    Disk(name: "Example 2", volumeType: "APFS", pathURL: URL(fileURLWithPath: "/Volumes/Example 1"), capacity: 250000, free: 20000, used: 20000, isEncrypted: true)
                ]
                controller.detailInformation.detectedDisks = disks
                controller.detailInformation.selectedDisk = disks.first
                controller.detailInformation.user.remotePassword = "Example"
                controller.detailInformation.user.remotePasswordVerified = true
                controller.detailInformation.user.localPassword = "Example"
                return controller
            }())
        
        ContentView(user: User("Example 1"))
            .frame(width: 800, height: 600)
            .environmentObject({ () -> MigrationController in
                let controller = MigrationController()
                controller.currStep = .Verification
                controller.stopDiskDetection()
                let disks = [
                    Disk(name: "Example 1", volumeType: "APFS", pathURL: URL(fileURLWithPath: "/Volumes/Example 1"), capacity: 250000, free: 20000, used: 20000, isEncrypted: true),
                    Disk(name: "Example 2", volumeType: "APFS", pathURL: URL(fileURLWithPath: "/Volumes/Example 1"), capacity: 250000, free: 20000, used: 20000, isEncrypted: true)
                ]
                controller.detailInformation.detectedDisks = disks
                controller.detailInformation.selectedDisk = disks.first
                controller.detailInformation.user.remotePassword = "Example"
                controller.detailInformation.user.remotePasswordVerified = true
                controller.detailInformation.user.localPassword = "Example"
                controller.detailInformation.user.remoteFolder = Folder(name: "Example", urlPath: URL(fileURLWithPath: "/Volumes/RemoteDrive/Users/Example"), size: 1500000)
                controller.detailInformation.user.localFolder = Folder(name: "Example", urlPath: URL(fileURLWithPath: "/Users/Example"), size: 1500000)
                return controller
            }())
        
        ContentView(user: User("Example 1"))
            .frame(width: 800, height: 600)
            .environmentObject({ () -> MigrationController in
                let controller = MigrationController()
                controller.currStep = .Migration
                controller.stopDiskDetection()
                let disks = [
                    Disk(name: "Example 1", volumeType: "APFS", pathURL: URL(fileURLWithPath: "/Volumes/Example 1"), capacity: 250000, free: 20000, used: 20000, isEncrypted: true),
                    Disk(name: "Example 2", volumeType: "APFS", pathURL: URL(fileURLWithPath: "/Volumes/Example 1"), capacity: 250000, free: 20000, used: 20000, isEncrypted: true)
                ]
                controller.detailInformation.detectedDisks = disks
                controller.detailInformation.selectedDisk = disks.first
                controller.detailInformation.user.remotePassword = "Example"
                controller.detailInformation.user.remotePasswordVerified = true
                controller.detailInformation.user.localPassword = "Example"
                controller.detailInformation.user.remoteFolder = Folder(name: "Example", urlPath: URL(fileURLWithPath: "/Volumes/RemoteDrive/Users/Example"), size: 1500000)
                controller.detailInformation.user.localFolder = Folder(name: "Example", urlPath: URL(fileURLWithPath: "/Users/Example"), size: 1500000)
                return controller
            }())
        
        ContentView(user: User("Example 1"))
            .frame(width: 800, height: 600)
            .environmentObject({ () -> MigrationController in
                let controller = MigrationController()
                controller.currStep = .Logoff
                controller.stopDiskDetection()
                let disks = [
                    Disk(name: "Example 1", volumeType: "APFS", pathURL: URL(fileURLWithPath: "/Volumes/Example 1"), capacity: 250000, free: 20000, used: 20000, isEncrypted: true),
                    Disk(name: "Example 2", volumeType: "APFS", pathURL: URL(fileURLWithPath: "/Volumes/Example 1"), capacity: 250000, free: 20000, used: 20000, isEncrypted: true)
                ]
                controller.detailInformation.detectedDisks = disks
                controller.detailInformation.selectedDisk = disks.first
                controller.detailInformation.user.remotePassword = "Example"
                controller.detailInformation.user.remotePasswordVerified = true
                controller.detailInformation.user.localPassword = "Example"
                controller.detailInformation.user.remoteFolder = Folder(name: "Example", urlPath: URL(fileURLWithPath: "/Volumes/RemoteDrive/Users/Example"), size: 1500000)
                controller.detailInformation.user.localFolder = Folder(name: "Example", urlPath: URL(fileURLWithPath: "/Users/Example"), size: 1500000)
                return controller
            }())
    }
}
