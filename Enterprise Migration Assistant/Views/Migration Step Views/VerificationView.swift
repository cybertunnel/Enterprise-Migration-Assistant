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
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128, height: 128)
                    .padding()
                Text("Verify Settings Prior to Migrating")
                    .font(.title)
            }
            .padding()
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    VStack(alignment: .center) {
                        Text("Local Information")
                            .font(.title2)
                    }
                    HStack {
                        Text("Username:")
                        Text(self.migrationController.detailInformation.user.username)
                    }
                    HStack {
                        Text("Local Folder:")
                        Text(self.migrationController.detailInformation.user.localFolder?.urlPath.path ?? "")
                    }
                    HStack {
                        Text("Enough Free:")
                        Text(self.migrationController.detailInformation.enoughFreeSpace.description)
                    }
                }
                .padding()
                .border(Color.gray, width: 2)
                
                VStack(alignment: .leading) {
                    Text("Remote Information")
                        .font(.title2)
                    HStack {
                        Text("Remote Folder:")
                        Text(self.migrationController.detailInformation.user.remoteFolder?.urlPath.path ?? "")
                    }
                    HStack {
                        Text("Remote Folder Size:")
                        Text(self.migrationController.detailInformation.user.remoteFolder?.sizeOnDiskString ?? "")
                    }
                    HStack {
                        Text("Remote Password Verified:")
                        Text(self.migrationController.detailInformation.user.remotePasswordVerified.description)
                    }
                }
                .padding()
                .border(Color.gray, width: 2)
                Spacer()
            }
            Spacer()
        }
    }
}

struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationView()
            .frame(width: 800, height: 600)
            .environmentObject({ () -> MigrationController in
                let controller = MigrationController()
                controller.detailInformation.user = User("ExampleUser")
                controller.detailInformation.user.remoteFolder = Folder(name: "Example", urlPath: URL(fileURLWithPath: "/Volumes/Remote Disk/Users/Example"), size: 1000000)
                controller.detailInformation.user.localFolder = Folder(name: "Example", urlPath: URL(fileURLWithPath: "/Users/exampleUser"))
                return controller
            }())
    }
}
