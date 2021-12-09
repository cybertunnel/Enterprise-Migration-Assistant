//
//  DiskSelectionView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/9/21.
//

import SwiftUI
import XPC

struct DiskSelectionView: View {
    @EnvironmentObject var migrationController: MigrationController
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Image("harddisk")
                    .padding()
                Text("Disk Selection")
                    .font(.title)
                if self.migrationController.detectedDisks.isEmpty {
                    Spacer()
                    Text("No Disks Found!")
                        .font(.title2)
                }
            }
            .padding()
            VStack(alignment: .leading) {
                if self.migrationController.detectedDisks.isEmpty {
                    // Let's show how to get started.
                    Spacer()
                    Text("You can now migrate your data from your old Mac.")
                    Text("1. Turn your old Mac off.")
                    Text("2. Connect your old Mac and new Mac together using the supplied Thunderbolt cable.")
                    Text("3. Power on your old Mac by normally pressing the power button WHILE holding the \"T\" button down for several seconds.")
                    Spacer()
                    Text("We will attempt to detect your old Mac now...")
                } else {
                    Text("Please select your old Mac:")
                        .font(.title2)
                    DiskListView(disks: self.migrationController.detectedDisks, selectedDisk: self.$migrationController.selectedDisk)
                }
            }
            .padding()
            Spacer()
        }
    }
}

struct DiskSelectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        DiskSelectionView()
            .frame(width: 800, height: 600)
            .environmentObject(MigrationController())
        
        DiskSelectionView()
            .frame(width: 800, height: 600)
            .environmentObject({ () -> MigrationController in
                let controller = MigrationController()
                controller.detectedDisks = [
                    Disk(name: "Example 1", volumeType: "APFS", pathURL: URL(fileURLWithPath: "/Volumes/Example 1"), capacity: 250000, free: 20000, used: 20000, isEncrypted: true),
                    Disk(name: "Example 2", volumeType: "APFS", pathURL: URL(fileURLWithPath: "/Volumes/Example 1"), capacity: 250000, free: 20000, used: 20000, isEncrypted: true)
                ]
                controller.selectedDisk = controller.detectedDisks[0]
                return controller
            }())
    }
}
