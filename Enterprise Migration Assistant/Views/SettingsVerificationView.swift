//
//  SettingsVerificationView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/8/21.
//

import SwiftUI

struct SettingsVerificationView: View {
    let user: User
    let hasEnoughFree: Bool = false
    var body: some View {
        VStack {
            Text("Settings Confirmation")
                .font(.title2)
            Spacer()
            Text("Remote Folder:")
            Text(self.user.remoteFolder?.urlPath.path ?? "")
        }
    }
}

struct SettingsVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsVerificationView(user: User("Example"))
    }
}
