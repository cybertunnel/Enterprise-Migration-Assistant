//
//  MigrationView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/9/21.
//

import SwiftUI

struct MigrationView: View {
    @EnvironmentObject var migrationController: MigrationController
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Image("check")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128, height: 128)
                    .padding()
                Text("Migration in Progress")
                    .font(.title)
                Spacer()
            }
            .padding()
            
            VStack {
                ProgressBar(totalValue: Double(self.migrationController.detailInformation.targetFolderSize), currValue: Double(self.migrationController.detailInformation.currFolderSize))
                    .frame(height: 16)
                Text("Progress: \(String(describing: self.migrationController.detailInformation.currFolderSize)) of \(String(describing: self.migrationController.detailInformation.targetFolderSize))")
                    .font(.caption)
                Spacer()
            }
            .padding()
        }
    }
}

struct MigrationView_Previews: PreviewProvider {
    static var previews: some View {
        MigrationView()
            .environmentObject({ () -> MigrationController in
                let controller = MigrationController()
                controller.detailInformation.currFolderSize = 50
                controller.detailInformation.targetFolderSize = 75
                return controller
            }())
            .frame(width: 800, height: 600)
    }
}
