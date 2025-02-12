//
//  PasswordManagerAdd.swift
//  PasswordManager
//
//  Created by Christian Hernandez on 2/12/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CryptoKit

class PasswordManagerAdd: ObservableObject {
    private let db = Firestore.firestore()
    
    //function to allow encrypt passwords before storing them to the firestore
    private func encryptPassword( _ password: String) -> String? {
        let key = SymmetricKey(size: .bits256)
        let passwordData = password.data(using: .utf8)!
        let sealedBox = try?AES.GCM.seal(passwordData, using: key)
        return sealedBox?.combined?.base64EncodedString()
    }
    
    //this function will allow to store the passwords in firestore
    func savePassword(title: String, emailOrUsername: String, password: String, completion: @escaping (Bool, String) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not logged in------")
            completion(false, "User not logged in.")
            return
        }
        print("Logged-IN User ID: \(userID)-----")
        guard let encryptedPassword = encryptPassword(password) else {
            completion(false, "Failed to encrypt password.")
            return
        }
        
        //this contains the password data that we need to add an password
        let passwordData: [String: Any] = [
            "title": title,
            "emailOrUsername": emailOrUsername,
            "encryptedPassword": encryptedPassword,
            "createdAt": Timestamp()
        ]
        
        db.collection("users").document(userID).collection("passwords").addDocument(data: passwordData) { error in
            if let error = error {
                print("FIRESTORE write Error: \(error.localizedDescription)-----------")
                completion(false, "Error saving password: \(error.localizedDescription)")
            }
            else {
                print("Password saved successfully!!!!----------")
                completion(true, "Password saved successfully!")
            }
        }
    }
    //this function will now retreive stored password from firestore and we are using the struct that we created and turn to an array
    func fetchPasswords(completion: @escaping ([PasswordEntry]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userID).collection("passwords")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching password: \(error?.localizedDescription ?? "Unknown Error")")
                    return
                }
                let passwords = documents.compactMap{doc -> PasswordEntry? in
                    let data = doc.data()
                    return PasswordEntry(id: doc.documentID, title: data["title"] as? String ?? "", emailOrUsername: data["emailOrUsername"] as? String ?? "", encryptedPassword: data["encryptedPassword"] as? String ?? "")
                }
                DispatchQueue.main.async {
                    completion(passwords)
                }
            }
    }
    //this will now delete the password from the firestore
    func deletePassword(passwordID: String, completion: @escaping (Bool, String) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false, "User not logged in.")
            return
        }
        
        db.collection("users").document(userID).collection("passwords").document(passwordID).delete { error in
            if let error = error {
                print("Firestore Delete Error: \(error.localizedDescription)")
                completion(false, "Error deleting password: \(error.localizedDescription)")
            } else {
                print("Password deleted successfully!")
                completion(true, "Password deleted successfully!")
            }
        }
    }
}


//this struct will demonstrates what information password the user can store
struct PasswordEntry: Identifiable {
    var id: String
    var title: String
    var emailOrUsername: String
    var encryptedPassword: String
}
