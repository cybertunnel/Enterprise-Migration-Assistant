//
//  main.swift
//  Migrator Tool
//
//  Created by Morgan, Tyler on 12/10/21.
//

import Foundation
import SwiftUI

enum MigratorToolError: Error {
    case InvalidNumberOfParameters
}

// TODO: Add keychain updating
let arguments = Array(CommandLine.arguments.dropFirst())

if arguments.count < 3 { exit(404) }

let user = arguments[0]
let password = arguments[1]
let oldPassword = arguments[2]


struct App: SwiftUI.App {
    @State private var window: NSWindow?
    @StateObject private var controller: FinalTouchesController = FinalTouchesController(loggedInUser: "", username: user, password: password)
    
    var body: some Scene {
    WindowGroup {
      VStack {
          Text("Finishing the migration")
          Text("Please wait...")
              .font(.title)
              .foregroundColor(Color.white)
      }
      .frame(width: NSScreen.main?.frame.width ?? .greatestFiniteMagnitude, height: NSScreen.main?.frame.height ?? .greatestFiniteMagnitude)
      //.background(WindowAccessor(window: $window))
      //.background(Color.black)
      //.edgesIgnoringSafeArea(.all)
    }
      .windowStyle(.hiddenTitleBar)
  }
}

App.main()


