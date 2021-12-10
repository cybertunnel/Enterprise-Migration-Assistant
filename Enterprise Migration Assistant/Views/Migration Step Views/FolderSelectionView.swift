//
//  FolderSelectionView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/9/21.
//

import SwiftUI

struct FolderSelectionView: View {
    @EnvironmentObject var migrationController: MigrationController
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Image("folder")
                    .padding()
                Text("Folder Selection")
                    .font(.title)
                if let error = self.migrationController.error {
                    ErrorView(error: error)
                }
                else if self.migrationController.selectedDiskFolders.isEmpty {
                    Spacer()
                    Text("Detecting folders...")
                        .font(.title)
                }
                Spacer()
            }
            .padding()
            if !self.migrationController.selectedDiskFolders.isEmpty {
                FolderViewList(selectedFolder: self.$migrationController.selectedUserFolder, folders: self.migrationController.selectedDiskFolders)
            }
        }
    }
}

struct FolderSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        
        FolderSelectionView()
            .frame(width: 800, height: 600)
            .environmentObject(MigrationController())
        
        FolderSelectionView()
            .frame(width: 800, height: 600)
            .environmentObject({ () -> MigrationController in
                let controller = MigrationController()
                controller.selectedDiskFolders = [
                    Folder(name: "Example 1", urlPath: URL(fileURLWithPath: "/Users/Example 1"), size: 1500000),
                    Folder(name: "Example 2", urlPath: URL(fileURLWithPath: "/Users/Example 1"), size: 1500000)
                    
                ]
                controller.selectedUserFolder = controller.selectedDiskFolders[0]
                
                return controller
            }())
    }
}
