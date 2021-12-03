//
//  ProgressBar.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/2/21.
//

import Foundation
import SwiftUI

struct ProgressBar: View {
    var totalValue: Double
    var currValue: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(NSColor.systemTeal))
                Rectangle().frame(width: geometry.size.width * (currValue / totalValue), height: geometry.size.height)
                    .foregroundColor(Color(NSColor.systemBlue))
            }.cornerRadius(45.0)
        }
    }
}
