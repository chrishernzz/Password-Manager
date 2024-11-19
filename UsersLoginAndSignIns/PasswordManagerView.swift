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
    //function will allow the user to add the password information
    func addPassword(for user: User, title: String, emailOrusername: String, password: String) {
        //call the entity Password and pass in the values
        let newPassword = Password(context: context)
        newPassword.title = title
        newPassword.emailOrusername = emailOrusername
        newPassword.password = password
        newPassword.user = user

        do {
            //save the content to the core data 
            try context.save()
            print("Password saved successfully for user: \(user.email ?? "unknown")")
        } catch {
            print("Error saving password: \(error.localizedDescription)")
        }
    }
}
