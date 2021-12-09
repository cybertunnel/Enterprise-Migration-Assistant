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
                Text("Transferring your files now")
                    .font(.title)
                    .padding()
                Spacer()
            }
            else if self.migrationController.currStep == .InformationVerification {
                InputRequestView(user: self.$migrationController.user)
                    .environmentObject(self.migrationController.user)
                if self.migrationController.user.remotePasswordVerified {
                    Text("YAY!")
                }
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
                    .disabled(true)
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
                            self.migrationController.startMigration()
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
        ContentView(user: User("Example 1"))
            .frame(width: 800, height: 600)
    }
}
