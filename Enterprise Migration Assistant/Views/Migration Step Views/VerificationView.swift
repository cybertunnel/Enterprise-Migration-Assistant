//
//  VerificationView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/9/21.
//

import SwiftUI
import XPC

struct VerificationView: View {
    @EnvironmentObject var migrationController: MigrationController
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Image("check")
                    .padding()
                Text("Verify Settings Prior to Migrating")
                    .font(.title)
                Spacer()
            }
            .padding()
            
            VStack {
                Text("Username: \(self.migrationController.user.username)")
                Text("Local Path: \(self.migrationController.user.localFolder?.urlPath.path ?? "NOT SET")")
                Text("Remote Source: \(self.migrationController.user.remoteFolder?.urlPath.path ?? "NOT SET")")
                Text("Remote Size: \(self.migrationController.user.remoteFolder?.sizeOnDiskString ?? "NOT SET")")
            }
        }
    }
}

struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationView()
            .frame(width: 800, height: 600)
            .environmentObject({ () -> MigrationController in
                let controller = MigrationController()
                controller.user = User("ExampleUser")
                controller.user.remoteFolder = Folder(name: "Example", urlPath: URL(fileURLWithPath: "/Volumes/Remote Disk/Users/Example"), size: 1000000)
                controller.user.localFolder = Folder(name: "Example", urlPath: URL(fileURLWithPath: "/Users/exampleUser"))
                return controller
            }())
    }
}
