//
//  PasswordView.swift
//  PasswordManager
//
//  Created by Christian Hernandez on 9/14/24.
//

import Foundation
import SwiftUI

struct HomePageView: View{
    /*as for binding, it will allow the child view to modify(read and write)
     the parents view which is homepageview*/
    @Binding var authenticatedPass: Bool
    @Binding var showAlert: Bool
    @Binding var message: String
    //stays local to this view only
    @State private var email: String = ""
    @State private var password: String = ""
    
    //create an observed that will allow us to observed the ObservableObject
    @ObservedObject var authMangager = AuthManager()
    
    //will keep track of what field is active-> won't know if it has a value or if it is nil
    @FocusState private var focusedField: Field?
    enum Field {
        case email, password
    }
    
    
    var body: some View{
        ZStack {
            Color.gray.edgesIgnoringSafeArea(.all)
            //VStack: top to bottom
            VStack{
                Text("KodiCrew Mysterious")
                    .foregroundColor(.black)
                    .font(.largeTitle)
                    .padding(.top, -100)
                VStack(alignment: .leading, spacing: 10){
                    Text("Email")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(.leading, 2)
                        .padding(.bottom, -10)
                    TextField("Email",text: $email)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .colorScheme(.light)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit{
                            focusedField = .password
                        }
                    
                    Text("Password")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(.top, 5)
                        .padding(.leading, 2)
                        .padding(.bottom, -10)
                    //the characters are going to be hidden since it is password
                    SecureField("Password",text: $password)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .colorScheme(.light)
                        .focused($focusedField, equals: .password)
                        //we want the button to say "Done" since there are no more inputs that we need to add
                        .submitLabel(.done)
                        .onSubmit {
                            //will dismiss the keyboard
                            focusedField = nil
                        }
                }
                .padding(.horizontal)
                //need the login and sign up button side to side so use HStack-> indicates the horizontal
                HStack{
                    /*going to create button one that is login and one that is sign up*/
                    Button(action: {
                        loginUser()
                    }){
                        Text("Login")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        signUpUser()
                    }) {
                        Text("Sign Up")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                //call variable showAlert and this will hold the alert and is able to share a two way data connection
                .alert(isPresented: $showAlert){
                    /*message: will display a message in the alert, passing in Text(with the variable that was created and has the message of the alert), */
                    Alert(title: Text(""), message: Text(message), dismissButton: .default(Text("OK")))
                }
                
            }
            .padding()
        }
    }
    //function to now read if the user exits
    func loginUser() {
        //call the function where you validate the inputs
        guard validUserInformation() else { return }
        
        authMangager.loginUser(email: email, password: password) { success, message in
            DispatchQueue.main.async {
                self.message = message
                self.showAlert = true
                if success {
                    authenticatedPass = true
                }
                email = ""
                password = ""
            }
        }
    }
    //function for keeping track of the sign ups
    func signUpUser() {
        guard validUserInformation() else { return }
        
        authMangager.signUpUser(email: email, password: password) { success, message in
            DispatchQueue.main.async {
                self.message = message
                self.showAlert = true
                if success {
                    authenticatedPass = true
                }
                email = ""
                password = ""
            }
        }
    }
    
    //function makes sure it allows the '@' symbol
    func isValidEmail(_ email: String) -> Bool {
        // Regular expression to validate email
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        //predicate will filter the results-> will filter the fetcching
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    //function is going to check for the user input validation
    func validUserInformation() -> Bool {
        //check if the user tries to sign up without inputing, then error right away
        if (email.isEmpty && password.isEmpty) {
            message = "Email and Password cannot be empty. Please enter your information."
            showAlert = true
            return false
        }
        if (email.isEmpty) {
            message = "Email cannot be empty. Please enter your email."
            showAlert = true
            return false
        }
        //validates the email here-> call the function to make sure it uses '@'
        if !isValidEmail(email) {
            message = "Please enter a valid email address (e.g., user@gmail.com)."
            showAlert = true
            return false
        }
        if (password.isEmpty) {
            message = "Password cannot be empty. Please enter your password."
            showAlert = true
            return false
        }
        return true
    }
}


struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView(
            authenticatedPass: .constant(false),
            showAlert: .constant(false),
            message: .constant("")
        )
    }
}
