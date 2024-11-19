//
//  PasswordManagerView.swift
//  PasswordManager
//
//  Created by Christian Hernandez on 9/19/24.
//

import CoreData
import SwiftUI

class PasswordManagerView: ObservableObject {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addPassword(for user: User, title: String, emailOrusername: String, password: String) {
        let newPassword = Password(context: context)
        newPassword.title = title
        newPassword.emailOrusername = emailOrusername
        newPassword.password = password
        newPassword.user = user

        do {
            try context.save()
            print("Password saved successfully for user: \(user.email ?? "unknown")")
        } catch {
            print("Error saving password: \(error.localizedDescription)")
        }
    }
}
