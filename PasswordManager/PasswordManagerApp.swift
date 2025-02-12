//
//  PasswordManagerApp.swift
//  PasswordManager
//
//  Created by Christian Hernandez on 9/14/24.
//

import SwiftUI
import CoreData
import Firebase


@main
struct PasswordManagerApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

