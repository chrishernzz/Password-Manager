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
        //this is like an if else, if valid then go on else give an error
        guard let encryptedPassword = PasswordCryptoManager.encryptPassword(password) else {
            print("Failed to encrypt the password.")
            return
        }
        //DEBUGGING PURPOSES
        print("Encrypted Password: \(encryptedPassword.base64EncodedString())")
        // Decrypt the password to verify it works
        if let decryptedPassword = PasswordCryptoManager.decryptPassword(encryptedPassword) {
            print("Decrypted Password: \(decryptedPassword)")
        } else {
            print("Failed to decrypt the password.")
        }
        //call the entity Password then pass in the information-> intialize it
        let newPassword = Password(context: context)
        newPassword.title = title
        newPassword.emailOrusername = emailOrusername
        newPassword.encryptedPassword = encryptedPassword
        newPassword.user = user

        do {
            //alwasy save so it can go to the core data
            try context.save()
            print("Password saved successfully for user: \(user.email ?? "unknown")")
        } catch {
            print("Error saving password: \(error.localizedDescription)")
        }
    }

}
