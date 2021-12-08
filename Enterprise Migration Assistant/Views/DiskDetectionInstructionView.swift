//
//  DiskDetectionInstructionView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/8/21.
//

import SwiftUI

struct DiskDetectionInstructionView: View {
    let instructions = "Please follow the below instructions:\n1.\t Turn off your old Mac\n2.\tConnect your old Mac and new Mac together using the supplied Thunderbolt cable.\n3.\tPower on your old Mac by normally pressing the power button WHILE holding the \"T\" button down for several seconds."
    var body: some View {
        VStack {
            Text("No Disks Detected!")
                .font(.headline)
            Text(instructions)
            Spacer()
            Text("We will automatically detect your disk.")
        }
    }
}

struct DiskDetectionInstructionView_Previews: PreviewProvider {
    static var previews: some View {
        DiskDetectionInstructionView()
    }
}
