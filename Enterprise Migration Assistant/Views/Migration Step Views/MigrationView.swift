//
//  MigrationView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/9/21.
//

import SwiftUI

struct MigrationView: View {
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Image("check")
                    .padding()
                Text("Migration in Progress")
                    .font(.title)
                Spacer()
            }
            .padding()
            
            VStack {
                ProgressBar(totalValue: 122023921039124, currValue: 432045)
                    .frame(height: 16)
                Text("Progress: ")
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
            .frame(width: 800, height: 600)
    }
}
