//
//  InstructionView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 11/18/21.
//

import SwiftUI

struct InstructionView: View {
    @State var isAppleSilicon: Bool = false
    @State var isIntel: Bool = true
    var body: some View {
        VStack {
            Image(systemName: NSImage.cautionName)
                .frame(width: 50.0, height: 50.0)
                .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.gray/*@END_MENU_TOKEN@*/)
                .padding()
            Text("Enterprise Migration Assistant")
            HStack {
                Toggle(isOn: self.$isAppleSilicon) {
                    Text("Apple Silicon")
                        .padding()
                }
                Toggle(isOn: self.$isIntel) {
                    Text("Intel")
                        .padding()
                }
            }
            
            VStack {
                Text("You can now migrate your data from your old Mac.")
                Text("1. Turn your old Mac off.")
                Text("2. Connect your old Mac and new Mac together using the supplied Thunderbolt cable.")
                Text("3. Power on your old Mac by normally pressing the power button WHILE holding the \"T\" button down for several seconds.")
                Spacer()
                Text("We will attempt to detect your old Mac now...")
            }
            .padding()
        }
        
    }
}

struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionView()
            
    }
}
