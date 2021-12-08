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
                Image(systemName: NSImage.cautionName)
                    .padding()
                    .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.black/*@END_MENU_TOKEN@*/)
                    .scaleEffect()
                VStack(alignment: .leading) {
                    Text(self.disk.name)
                    Text(self.disk.volumeType)
                }
                
                Spacer()
                Text(self.disk.capacityString)
                    .padding()
                    .border(Color(NSColor.systemGray), width: 2)
                    .cornerRadius(5)
                    .background(Color(NSColor.clear))
            }
            .padding()
            ProgressBar(totalValue: Double(self.disk.capacity), currValue: Double(self.disk.used)).frame(height: 20)
            HStack {
                Rectangle()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color(NSColor.systemBlue))
                VStack(alignment: .leading) {
                    Text("Used")
                        .bold()
                    Text("\(self.disk.usedString)")
                }
                Spacer()
                Rectangle()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color(NSColor.systemTeal))
                VStack(alignment: .leading) {
                    Text("Free")
                        .bold()
                    Text("\(self.disk.freeString)")
                }
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
