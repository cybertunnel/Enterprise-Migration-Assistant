//
//  DiskView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 11/18/21.
//

import SwiftUI

struct DiskView: View {
    let disk: Disk
    var body: some View {
        if #available(macOS 11.0, *) {
            HStack {
                Image(systemName: NSImage.cautionName)
                    .padding()
                    .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.black/*@END_MENU_TOKEN@*/)
                VStack {
                    Text(self.disk.name)
                    Text(self.disk.volumeType)
                    Text("\(self.disk.freeString) Free")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct DiskView_Previews: PreviewProvider {
    static var previews: some View {
        let exampleDisk = Disk(
            name: "Macintosh HD",
            mediaBSDName: "/dev/disk1s2",
            volumeType: "apfs",
            mediaContent: "Something",
            pathURL: URL(string: "file:///Volumes/Macintosh HD")!,
            capacity: 5000000,
            free: 45000,
            used: 5000000 - 45000,
            isEncrypted: false
        )
        DiskView(disk: exampleDisk)
    }
}
