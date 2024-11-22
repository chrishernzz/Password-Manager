//
//  StorePasswordsView.swift
//  PasswordManager
//
//  Created by Christian Hernandez on 9/14/24.
//

import Foundation
import SwiftUI
import CoreData

struct StorePasswordsView: View {
    @Environment(\.managedObjectContext) private var context
    var loggedInUser: User
    @State private var passwords: [Password] = []
    @State private var visiblePasswordIndex: Int? = nil

    var body: some View {
        NavigationView {
            List {
                ForEach(passwords.indices, id: \.self) { index in
                    //this will hold the array-> index[0]...index[n]
                    let password = passwords[index]
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Title:")
                                .font(.headline)
                            Text(password.title ?? "Untitled")
                                .font(.body)
                        }
                        HStack {
                            Text("Email Or Username:")
                                .font(.headline)
                            Text(password.emailOrusername ?? "No Email/Username")
                                .font(.body)
                        }
                        HStack {
                            Text("Password:")
                                .font(.headline)
                            if (visiblePasswordIndex == index) {
                                if let decryptedPassword = PasswordCryptoManager.decryptPassword(password.encryptedPassword ?? Data()) {
                                    Text(decryptedPassword)
                                        .font(.body)
                                } 
                                else {
                                    Text("Decryption Failed")
                                        .font(.body)
                                }
                            } else {
                                Text(password.encryptedPassword?.base64EncodedString() ?? "No Encrypted Data")
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            Button(action: {
                                if (visiblePasswordIndex == index) {
                                    visiblePasswordIndex = nil
                                } 
                                else {
                                    visiblePasswordIndex = index
                                }
                            }) {
                                Image(systemName: visiblePasswordIndex == index ? "eye.fill" : "eye.slash.fill")
                                    .foregroundColor(.black )
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Stored Passwords")
            .onAppear {
                fetchPasswords()
            }
        }
    }
    //going to fetch which allows me to retrieve and read the data-> core data model
    private func fetchPasswords() {
        let fetchRequest: NSFetchRequest<Password> = Password.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@", loggedInUser)
        do {
            passwords = try context.fetch(fetchRequest)
        } catch {
            print("Error fetching passwords: \(error.localizedDescription)")
        }
    }
}



//struct StorePasswordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        StorePasswordsView(loggedInUser: { _ in }
//        )
//        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//    }
//}


