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
        VStack {
            HStack {
                Image(nsImage: NSImage(named: NSImage.computerName)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .padding(5)
                VStack(alignment: .leading) {
                    Text(self.disk.name)
                    Text(self.disk.volumeType)
                }
                
                Spacer()
                Text(self.disk.capacityString)
                    .padding(10)
                    .border(Color(NSColor.systemGray), width: 2)
                    .cornerRadius(5)
                    .background(Color(NSColor.clear))
            }
            .padding(5)
            ProgressBar(totalValue: Double(self.disk.capacity), currValue: Double(self.disk.used)).frame(height: 10)
            HStack {
                Rectangle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(Color(NSColor.systemBlue))
                Text("Used:")
                    .bold()
                Text("\(self.disk.usedString)")
                
                Spacer()
                
                Rectangle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(Color(NSColor.systemTeal))
                Text("Free:")
                    .bold()
                Text("\(self.disk.freeString)")
                Spacer()
                
                    
            }
        }
        .padding()
    }
}

struct DiskView_Previews: PreviewProvider {
    static var previews: some View {
        let exampleDisk = Disk(
            name: "Macintosh HD",
            volumeType: "apfs",
            pathURL: URL(fileURLWithPath: "/Volumes/Macintosh HD"),
            capacity: 10000000,
            free: 5000000,
            used: 10000000 - 5000000,
            isEncrypted: false)
        DiskView(disk: exampleDisk)
    }
}
