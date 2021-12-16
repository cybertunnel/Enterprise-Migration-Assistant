//
//  Enterprise_Migration_AssistantApp.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 11/17/21.
//

import SwiftUI
import OSLog

@main
struct Enterprise_Migration_AssistantApp: App {
    var body: some Scene {
        WindowGroup {
            let controller = MigrationController()
            ContentView(user: controller.user)
                .frame(width: 800, height: 600, alignment: .center)
                .environmentObject(controller)
        }
        // TODO: Add a "Testing" command to allow the ability to enable/disable testing
    }
}
