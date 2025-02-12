//
//  AddPasswordView.swift
//  PasswordManager
//
//  Created by Christian Hernandez on 9/14/24.
//

import Foundation
import SwiftUI

struct AddPasswordView: View {
    @ObservedObject var passwordManagerAdd = PasswordManagerAdd()
    
    //since using state is only access within this view
    @State private var title: String = ""
    @State private var emailOrusername: String = ""
    @State private var password: String = ""
    @State private var passwordStrengthMessage: String = ""
    @State private var passwordStrengthColor: Color = .gray
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Form {
            Section(header: Text("Website Details")) {
                TextField("Title", text: $title)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                TextField("Email or Username", text: $emailOrusername)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                SecureField("Password", text: $password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: password) { _ in
                        validatePasswordStrength(password)
                    }
                //this will indicate the message of the error
                Text(passwordStrengthMessage)
                    //this will be the color of the text
                    .foregroundColor(passwordStrengthColor)
                    .font(.footnote)
            }

            Button(action: {
                savePassword()
            }) {
                Text("Save Password")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(informationFilled ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!informationFilled)
            .alert(isPresented: $showAlert) {
                Alert(title: Text(""), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
            }
        }
    }
    //will check if it is not empty
    var informationFilled: Bool {
        return !title.isEmpty && !emailOrusername.isEmpty && !password.isEmpty
    }
    //this saves the password
    func savePassword() {
        if (!isPasswordValid(password)) {
            // Display a feedback message if the password is not valid
            passwordStrengthMessage = "Password is not strong enough."
            passwordStrengthColor = .red
            return
        }
        //if they are not empty then run this
        if (informationFilled) {
            passwordManagerAdd.savePassword(title: title, emailOrUsername: emailOrusername, password: password) { success, message in
                DispatchQueue.main.async {
                    self.alertMessage = message
                    self.showAlert = true
                    if success {
                        title = ""
                        emailOrusername = ""
                        password = ""
                        passwordStrengthMessage = ""
                        passwordStrengthColor = .gray
                    }
                }
            }
        }
    }
    //makes sure we use a character for upper and lower, number, and a hashtag
    func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>]).{6,}$"
        //predicate will filter the password
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    //function going to check how strong is the user password
    func validatePasswordStrength(_ password: String) {
        //if empty then error since you cannot have a password that is empty
        if (password.isEmpty) {
            passwordStrengthMessage = "Password cannot be empty."
            passwordStrengthColor = .red
        } 
        //has to have a length greater than 6
        else if (password.count < 6) {
            passwordStrengthMessage = "Password is too short. Minimum 6 characters."
            passwordStrengthColor = .orange
        }
        //call the function isPasswordValid that checks if it contains the information such as upper, lower, special characters
        else if (!isPasswordValid(password)) {
            passwordStrengthMessage = "Password must include an uppercase letter, a number, and a special character."
            passwordStrengthColor = .red
        } 
        //if has everything then the passwrod is strong
        else {
            passwordStrengthMessage = "Strong password!"
            passwordStrengthColor = .green
        }
    }
}

