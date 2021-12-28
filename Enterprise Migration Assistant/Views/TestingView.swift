//
//  TestingView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/28/21.
//

import SwiftUI

struct TestingView: View {
    @Binding var testingMode: Bool
    var body: some View {
        if testingMode {
            Text("Testing Mode")
                .font(.headline)
                .foregroundColor(Color.green)
                .padding(10)
                .border(Color.green, width: 2)
                .padding()
        }
    }
}

struct TestingView_Previews: PreviewProvider {
    static var previews: some View {
        TestingView(testingMode: .constant(true))
        
        TestingView(testingMode: .constant(false))
    }
}
