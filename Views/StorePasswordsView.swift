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
    //this will give us access to the entity type User
    var loggedInUser: User
    //this will hold the passwords for the users as an array
    @State private var passwords: [Password] = []

    var body: some View {
        NavigationView {
            //loop through the array and have to put the id since there is nonen
            List(passwords, id: \.self) { password in
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
                        Text(password.password ?? "No Password")
                            .font(.body)
                    }
                }
                .padding(.vertical, 5)
            }
            .navigationTitle("Stored Passwords")
            .onAppear {
                fetchPasswords()
            }
        }
    }

    //going to read the passwords from the users
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
