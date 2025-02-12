//
//  AuthManager.swift
//  PasswordManager
//
//  Created by Christian Hernandez on 2/12/25.
//
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

//observableobject protocol that will allow me to use published-> properteis can be observed for changes
class AuthManager: ObservableObject {
    //allows automatically refresh for amy views that are observed by this object
    @Published var authenticatedPass = false
    @Published var message = ""
    
    //create the firestore db
    private let db = Firestore.firestore()
    
    //function for keeping track of the sign ups
    func signUpUser(email: String, password: String, completion: @escaping (Bool,String)-> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Firebase Sign-Up Error: \(error.localizedDescription)")
                completion(false, "Sign up failed: \(error.localizedDescription)")
                return
            }
            guard let userID = authResult?.user.uid else {
                print("Firebase Sign-Up Failed: No user ID returned")
                return
            }
            
            //you now store the user details the firestore
            let userData: [String: Any] = [
                "email" : email,
                "createdAt" : Timestamp()
            ]
            self.db.collection("users").document(userID).setData(userData) { error in
                if let error = error {
                    print("Firestore Write Error: \(error.localizedDescription)")
                    completion(false, "Firestore error: \(error.localizedDescription)")
                }
                else {
                    print("User successfully created in Firestore: \(userID)")
                    completion(true, "Account Created Successfully!")
                }
            }
        }
    }
    //function to now read if the user exits
    func loginUser(email: String, password: String, completion: @escaping (Bool,String)-> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(false, "Login failed: \(error.localizedDescription)")
                return
            }
            guard let userID = authResult?.user.uid else { return }
            
            //you now keep track of logins in the firestore
            let loginData: [String: Any] = [
                "timestamp" : Timestamp()
            ]
            self.db.collection("users").document(userID).collection("logins").addDocument(data: loginData) { error in
                if let error = error {
                    completion(false, "Failed to track login: \(error.localizedDescription)")
                }
                else {
                    completion(true, "Login Successful!")
                }
            }
        }
    }
    
    //when user wants to sign out
    func signOutUser(completion: @escaping (Bool, String) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true, "Signed out successfully.")
        } catch let signOutError as NSError {
            completion(false, "Error signing out: \(signOutError.localizedDescription)")
        }
    }
}
