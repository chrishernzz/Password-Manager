//
//  PasswordManagerApp.swift
//  PasswordManager
//
//  Created by Christian Hernandez on 9/14/24.
//

import SwiftUI
import CoreData

@main
struct PasswordManagerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var passwordManager = PasswordManagerView(
        context: PersistenceController.shared.container.viewContext
    )
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(passwordManager) // Pass as environment object
        }
    }
}
