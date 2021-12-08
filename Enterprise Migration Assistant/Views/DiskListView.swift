//
//  DiskListView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/2/21.
//

import Foundation
import SwiftUI

struct DiskListView: View {
    let disks: Array <Disk>
    @Binding var selectedDisk: Disk?
    var body: some View {
        VStack {
            List(self.disks, id: \.self, selection: self.$selectedDisk) { disk in
                if self.selectedDisk == disk {
                    DiskView(disk: disk)
                        .onTapGesture {
                            //self.selectedDisk = disk
                        }
                        .border(Color(NSColor.systemBlue), width: 2)
                }
                else {
                    DiskView(disk: disk)
                        .onTapGesture {
                            //self.migrationController.selectedDisk = disk
                        }
                }
                
            }
        }
        .shadow(radius: 5)
    }
}

struct DiskListView_Previews: PreviewProvider {
    static var previews: some View {
        let exampleDisks = [
            Disk(
                name: "Macintosh HD",
                volumeType: "apfs",
                pathURL: URL(fileURLWithPath: "/Volumes/Macintosh HD"),
                capacity: 10000000,
                free: 5000000,
                used: 10000000 - 5000000,
                isEncrypted: false),
            Disk(
                name: "Macintosh HD",
                volumeType: "apfs",
                pathURL: URL(fileURLWithPath: "/Volumes/Macintosh HD"),
                capacity: 10000000,
                free: 5000000,
                used: 10000000 - 5000000,
                isEncrypted: false),
            Disk(
                name: "Macintosh HD",
                volumeType: "apfs",
                pathURL: URL(fileURLWithPath: "/Volumes/Macintosh HD"),
                capacity: 10000000,
                free: 5000000,
                used: 10000000 - 5000000,
                isEncrypted: false)
        ]
        DiskListView(disks: exampleDisks, selectedDisk: .constant(exampleDisks[2]))
            .frame(width: 400, height: 500)
    }
}
