//
//  ErrorView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/10/21.
//

import SwiftUI

struct ErrorView: View {
    let error: Error
    var body: some View {
        Text(self.error.localizedDescription)
            .foregroundColor(.red)
            .padding()
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: MigrationError.noUserFoldersDetected)
    }
}
