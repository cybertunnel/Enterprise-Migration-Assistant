//
//  ContentView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 11/17/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var migrationController = MigrationController()
    var body: some View {
        VStack {
            Text("Image Place Holder")
                .frame(width: 48, height: 48, alignment: .center)
                .padding()
            if self.migrationController.detectedDisks.count > 0 {
                DiskListView(disks: self.migrationController.detectedDisks, selectedDisk: self.$migrationController.selectedDisk)
            }
            
            if let folders = self.$migrationController.selectedDiskFolders.wrappedValue {
                if folders.count > 0 {
                    FolderViewList(selectedFolder: self.$migrationController.selectedUserFolder, folders: folders)
                }
            }
            Button("Detect Disk", action: self.migrationController.beginDiskDetection)
            Button("Detect Path", action: self.migrationController.detectPath)
            Button("Determine Space Requirements", action: self.migrationController.determineDiskUsage)
            Text(self.migrationController.selectedDisk?.name ?? "No Disk Selected")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
