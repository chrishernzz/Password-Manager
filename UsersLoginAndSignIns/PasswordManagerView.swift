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
        guard let encryptedPassword = PasswordCryptoManager.encryptPassword(password) else {
            print("Failed to encrypt the password.")
            return
        }
        print("Encrypted Password: \(encryptedPassword.base64EncodedString())")
        // Decrypt the password to verify it works
        if let decryptedPassword = PasswordCryptoManager.decryptPassword(encryptedPassword) {
            print("Decrypted Password: \(decryptedPassword)")
        } else {
            print("Failed to decrypt the password.")
        }

        let newPassword = Password(context: context)
        newPassword.title = title
        newPassword.emailOrusername = emailOrusername
        newPassword.encryptedPassword = encryptedPassword
        newPassword.user = user

        do {
            try context.save()
            print("Password saved successfully for user: \(user.email ?? "unknown")")
        } catch {
            print("Error saving password: \(error.localizedDescription)")
        }
    }

}
