//
//  VerifyPasswordView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/8/21.
//

import SwiftUI

struct VerifyPasswordView: View {
    @Binding var user: User
    var body: some View {
        VStack {
            Text("Information Requests and Validation")
                .font(.title)
            Spacer()
            VStack {
                Text("Keychain Passwords")
                    .font(.title2)
                Text("Local and remote passwords are needed to properly update your keychain.")
                    .font(.subheadline)
                Spacer()
                SecureField("Remote Keychain Password", text: self.$user.remotePassword)
                Spacer()
                SecureField("Local Keychain Password", text: self.$user.localPassword)
                Spacer()
                if self.user.remotePasswordVerified {
                    Text("VERIFIED!")
                }
            }
        }
        .padding()
    }
}

struct VerifyPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        let user = User("")
        VerifyPasswordView(user: .constant(user))
    }
}
