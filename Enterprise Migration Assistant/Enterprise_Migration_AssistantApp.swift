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
    @StateObject var controller = MigrationController()
    var body: some Scene {
        WindowGroup {
            ContentView(user: controller.detailInformation.user)
                .frame(width: 800, height: 600, alignment: .center)
                .environmentObject(controller)
        }
        .commands {
            CommandMenu("Development") {
                if self.controller.testingMode {
                    Button("Disable Testing Mode") {
                        self.controller.testingMode = false
                    }
                } else {
                    Button("Enable Testing Mode") {
                        self.controller.testingMode = true
                    }
                }
            }
        }
        // TODO: Add a "Testing" command to allow the ability to enable/disable testing
    }
}
