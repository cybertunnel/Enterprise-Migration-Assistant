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
            ForEach(self.migrationController.detectedDisks, id: \.self) {
                DiskView(disk: $0)
            }
            Button("Detect Disk", action: self.migrationController.beginDiskDetection)
            Button("Detect Path", action: self.migrationController.detectPath)
            Button("Determine Space Requirements") {
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
