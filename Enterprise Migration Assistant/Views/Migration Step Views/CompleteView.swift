//
//  CompleteView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/9/21.
//

import SwiftUI

struct CompleteView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image("check")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 128, height: 128)
                .padding()
            Text("Migration Complete")
                .font(.title)
            Spacer()
            Text("Your files have been moved over to a temporary directory. You will need to be logged out of your machine for the folder to be moved to it's final destination.")
            Spacer()
            Text("You can now unplug your old Mac.")
            Text("Do Not Unplug This System From Power")
                .font(.callout)
                .bold()
            Text("Once the login window is displayed again, you can then log into the machine.")
        }
        .padding()
    }
}

struct CompleteView_Previews: PreviewProvider {
    static var previews: some View {
        CompleteView()
            .frame(width: 800, height: 600)
    }
}
