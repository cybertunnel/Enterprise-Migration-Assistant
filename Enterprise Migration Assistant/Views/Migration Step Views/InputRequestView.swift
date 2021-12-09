//
//  InputRequestView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/9/21.
//

import SwiftUI

struct InputRequestView: View {
    //@EnvironmentObject var migrationController: MigrationController
    //@EnvironmentObject var user: User
    @Binding var user: User
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Image("inputForm")
                    .padding()
                Text("Additional Input Needed")
                    .font(.title)
                Spacer()
            }
            .padding()
            VStack {
                HStack {
                    Text("Password for your old Mac:")
                    SecureField("Remote Keychain Password", text: self.$user.remotePassword)
                    if !self.user.remotePassword.isEmpty {
                        if self.user.remotePasswordVerified {
                            Image(nsImage: NSImage(named: NSImage.statusAvailableName)!)
                        } else {
                            Image(nsImage: NSImage(named: NSImage.statusUnavailableName)!)
                        }
                    }
                }
                HStack {
                    Text("Password for this Mac:")
                    SecureField("Local Keychain Password", text: self.$user.localPassword)
                    if !self.user.localPassword.isEmpty {
                        if self.user.localPasswordVerified {
                            Image(nsImage: NSImage(named: NSImage.statusAvailableName)!)
                        } else {
                            Image(nsImage: NSImage(named: NSImage.statusUnavailableName)!)
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct InputRequestView_Previews: PreviewProvider {
    static var previews: some View {
        InputRequestView(user: .constant(User("Example 1")))
            .frame(width: 800, height: 600)
        
        InputRequestView(user: .constant({ () -> User in
            let user = User("Example 2")
            user.localPassword = "Example"
            user.remotePassword = "Example"
            user.remotePasswordVerified = true
            return user
        }()))
            .frame(width: 800, height: 600)
            //.environmentObject(User("Example 1"))
    }
}
