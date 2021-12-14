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

let arguments = Array(CommandLine.arguments.dropFirst())

if arguments.count < 5 { throw MigratorToolError.InvalidNumberOfParameters }

let path = arguments[0]
let oldUser = arguments[1]
let oldHome = arguments[2]
let oldPass = arguments[3]
let user = arguments[4]


struct App: SwiftUI.App {
    //@StateObject var controller = FinalTouchesController(loggedInUser: oldHome, username: user, password: oldPass)
  var body: some Scene {
    WindowGroup {
      VStack {
          Text("Finishing the migration")
          Text("Please wait...")
              .font(.title)
              .foregroundColor(Color.white)
      }
      .frame(width: NSScreen.main?.frame.width ?? 800, height: NSScreen.main?.frame.height ?? 600)
      .background(Color.black)
      
    }
      .windowStyle(.hiddenTitleBar)
  }
}

App.main()


