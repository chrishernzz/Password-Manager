//
//  StorePasswordsView.swift
//  PasswordManager
//
//  Created by Christian Hernandez on 9/14/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct StorePasswordsView: View {
    @ObservedObject private var passwordManager = PasswordManagerAdd()
    @State private var passwords: [PasswordEntry] = []
    @State private var visiblePasswordIndex: Int? = nil
    
    var body: some View {
        NavigationView {
            List {
                ForEach(passwords.indices, id: \.self) { index in
                    let password = passwords[index]
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Title:")
                                .font(.headline)
                            Text(password.title)
                                .font(.body)
                        }
                        HStack {
                            Text("Email Or Username:")
                                .font(.headline)
                            Text(password.emailOrUsername)
                                .font(.body)
                        }
                        HStack {
                            Text("Password:")
                                .font(.headline)
                            if visiblePasswordIndex == index {
                                //IDK YET
                                Text(decryptPassword(password.encryptedPassword))
                                    .font(.body)
                                    .foregroundColor(.blue)
                            } else {
                                Text("••••••••")
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            Button(action: {
                                visiblePasswordIndex = (visiblePasswordIndex == index) ? nil : index
                            }) {
                                Image(systemName: visiblePasswordIndex == index ? "eye.fill" : "eye.slash.fill")
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
                //going to use the .onDelete() method that will allow user to delete-> all you have to do is swipe, it is going to remove it
                .onDelete(perform: deletePassword)
            }
            .navigationTitle("Stored Passwords")
            .onAppear {
                fetchPasswords()
            }
        }
    }
    
    //going to fetch which allows users to retrieve and read the data from the firestore database
    private func fetchPasswords() {
        passwordManager.fetchPasswords { fetchedPasswords in
            self.passwords = fetchedPasswords
        }
    }
    
    //this function will allow user to delete an item (password they created)
    private func deletePassword(at offsets: IndexSet) {
        for index in offsets {
            let passwordToDelete = passwords[index]
            passwordManager.deletePassword(passwordID: passwordToDelete.id) { success, message in
                if success {
                    passwords.remove(at: index)
                } else {
                    print("Error deleting password: \(message)")
                }
            }
        }
    }
    
    //decrypt the password if user clicks on button
    private func decryptPassword(_ encryptedPassword: String) -> String {
        // TODO: Implement your actual decryption logic
        return "[Decrypted] \(encryptedPassword)"
    }
}
