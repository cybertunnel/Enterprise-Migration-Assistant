//
//  WelcomeView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/9/21.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .center) {
                Image("migration")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128, height: 128)
                    .padding()
                Text("Enterprise Migration Assistant")
                    .font(.title)
                Spacer()
                Text("If you have information on another Mac you can transfer to this Mac.")
                    .font(.headline)
            }
            .padding()
            Spacer()
            VStack {
                Text("Items you will need prior to starting this process:")
                Text("- Your old Mac\n- Supplied Thunderbolt cable\n- Power for your old and new Macs\n- Know password(s) for this and the old Mac.")
                    .padding()
            }
            .padding()
            Spacer()
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .frame(width: 800, height: 600)
    }
}
