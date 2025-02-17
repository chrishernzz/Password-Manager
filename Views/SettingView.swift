//
//  SettingView.swift
//  PasswordManager
//
//  Created by Christian Hernandez on 2/16/25.
//
import SwiftUI
import FirebaseAuth

struct SettingView: View {
    @Binding var isAuthenticated: Bool
    @ObservedObject var authManager = AuthManager()
    
    @State private var userEmail: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                //1st section
                Section(header: Text("Account")) {
                    //1st content
                    LabeledContent {
                        Text(userEmail)
                            .font(.body)
                            .foregroundColor(.black)
                    } label: {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.gray)
                            Text("User")
                                .font(.headline)
                        }
                    }
                    //2nd content
                    LabeledContent {
                        Button(action: {
                            resetPassword()
                        }) {
                            Text("Reset")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                    } label: {
                        HStack {
                            Image(systemName: "eye.slash.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.gray)
                            
                            Text("Password")
                                .font(.headline)
                        }
                    }
                }
                
                //2nd section
                Section {
                    SignOutView(isAuthenticated: $isAuthenticated)
                }
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            fetchUserEmail()
        }
    }
    //this will determine which user is logged in
    private func fetchUserEmail() {
        authManager.fetchUserLogins { email in
            self.userEmail = email
        }
    }
    //this will let user to reset thier main password
    private func resetPassword() {
        guard let email = Auth.auth().currentUser?.email else { return }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Password reset failed: \(error.localizedDescription)")
            } else {
                print("Password reset email sent!")
            }
        }
    }
}



//this will allow user to sign out
struct SignOutView: View {
    //binding will allow two way connection-> changes made here are going to be changed in the parent view
    @Binding var isAuthenticated: Bool
    @ObservedObject var authManager = AuthManager()
    
    var body: some View {
        VStack {
            Text("Are you sure you want to sign out?")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .frame(maxWidth: 300)
            Button(action: {
                authManager.signOutUser { success, message in
                    if success {
                        isAuthenticated = false
                    }
                    else {
                        print("Sign-out failed: \(message)")
                    }
                }
            }) {
                Text("Sign Out")
                    .frame(minWidth: 100, maxWidth: 200)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 10)
        }
        .frame(maxWidth: 320)
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}
