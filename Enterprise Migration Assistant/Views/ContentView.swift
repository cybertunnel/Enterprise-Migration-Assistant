//
//  ContentView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 11/17/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var migrationController: MigrationController
    var body: some View {
        VStack {
            if self.migrationController.currStep == .Welcome {
                Image("migration")
                    .padding()
                Text("Enterprise Migration Assistant")
                    .font(.title)
                    .padding()
                Spacer()
                VStack(alignment: .leading) {
                    Text("Welcome to the Enterprise Migration Assistant! Some of the things you will need are:")
                        .font(.title2)
                    Text("- Thunderbolt cable")
                    Text("- Charging cables (1 for your old device, and one for the current device")
                    Text("- Your old laptop's password, and your new laptop's password available")
                }
                Spacer()
            }
            else if self.migrationController.currStep == .DiskSelection {
                if self.migrationController.detectedDisks.isEmpty {
                    DiskDetectionInstructionView()
                } else {
                    Text("Select your source disk")
                        .font(.title)
                        .padding()
                    Spacer()
                    DiskListView(disks: self.migrationController.detectedDisks, selectedDisk: self.$migrationController.selectedDisk)
                }
            }
            else if self.migrationController.currStep == .FolderSelection {
                Text("Select your user folder")
                    .font(.title)
                    .padding()
                Spacer()
                FolderViewList(selectedFolder: self.$migrationController.selectedUserFolder, folders: self.migrationController.selectedDiskFolders ?? [])
            }
            else if self.migrationController.currStep == .Migration {
                Text("Transferring your files now")
                    .font(.title)
                    .padding()
                Spacer()
            }
            else if self.migrationController.currStep == .InformationVerification {
                Text("Some additional information need")
                    .font(.title)
                    .padding()
                VerifyPasswordView(user: self.$migrationController.user)
                Spacer()
                SettingsVerificationView(user: self.migrationController.user)
                if self.migrationController.user.remotePasswordVerified { Text("YAY!") }
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
                        switch self.migrationController.currStep {
                        case .FolderSelection:
                            self.migrationController.currStep = .DiskSelection
                        case .DiskSelection:
                            self.migrationController.currStep = .Welcome
                        case .InformationVerification:
                            self.migrationController.currStep = .FolderSelection
                        default:
                            print("Error")
                        }
                    }
                }
                
                if self.migrationController.currStep != .Logoff {
                    Button("Continue") {
                        switch self.migrationController.currStep {
                        case .Welcome:
                            self.migrationController.currStep = .DiskSelection
                        case .DiskSelection:
                            self.migrationController.stopDiskDetection()
                            self.migrationController.currStep = .FolderSelection
                        case .FolderSelection:
                            self.migrationController.currStep = .InformationVerification
                        case .InformationVerification:
                            self.migrationController.currStep = .Migration
                        default:
                            print("Error")
                        }
                    }
                    .disabled(!self.migrationController.canProceed)
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 800, height: 600)
    }
}
