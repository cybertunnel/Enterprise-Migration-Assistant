//
//  WindowAccessor.swift
//  Migrator Tool
//
//  Created by Morgan, Tyler on 12/14/21.
//

import Foundation
import SwiftUI

struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?
    
    func makeNSView(context: Context) -> some NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.window = view.window
        }
        
        DispatchQueue(label: "Testing", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil).async {
            while true {
                DispatchQueue.main.async {
                    self.window?.makeKeyAndOrderFront(nil)
                }
                sleep(5)
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        // Nothing
    }
}
