//
//  PasswordView.swift
//  PasswordManager
//
//  Created by Christian Hernandez on 9/14/24.
//

import Foundation
import SwiftUI
import CoreData

struct HomePageView: View{
    /*as for binding, it will allow the child view to modify(read and write)
     the parents view which is homepageview*/
    @Binding var authenticatedPass: Bool
    @Binding var showAlert: Bool
    @Binding var message: String
    //stays local to this view only
    @State private var email: String = ""
    @State private var password: String = ""
    
    //going to create it globally so now you can access it in any view
    @Environment(\.managedObjectContext) private var context
    //closure function that takes in User (entity) as an parameter
    var loginSuccess: (User) -> Void
    
    var body: some View{
        ZStack {
            Color.gray.edgesIgnoringSafeArea(.all)
            //VStack: top to bottom
            VStack{
                Text("Double00 Mysterious")
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
                        .cornerRadius(8) // Optional for rounded corners
                        .foregroundColor(.black)
                        .colorScheme(.light)
                    
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
                        .cornerRadius(8) // Optional for rounded corners
                        .foregroundColor(.black)
                        .colorScheme(.light)
                }
                .padding(.horizontal)
                HStack{
                    /*going to create button one that is login and one that is sign up*/
                    Button(action: {
                        loginUser(context: context)
                    }){
                        Text("Login")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        signUpUser(context: context)
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
    func loginUser(context: NSManagedObjectContext) {
        //call the function here
        if !validUserInformation() {return}
        
        //going to fetch request which allows us to read
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        do {
            //unwrapping and we are looking for the first email (unique)
            if let user = try context.fetch(fetchRequest).first {
                if (user.password == password) {
                    authenticatedPass = true
                    message = "Login Successful!"
                    //pass the whole thing in the information-> the login was a success
                    loginSuccess(user)
                }
                else {
                    message = "Incorrect password. Please try again."
                }
            } 
            //if no user found-> will return nil means empty
            else {
                message = "No account found for this email. Please sign up."
            }
        } catch {
            message = "Failed to log in. Please try again."
        }
        showAlert = true
        email = ""
        password = ""
    }
    //function for keeping track of the sign ups
    func signUpUser(context: NSManagedObjectContext) {
        //call the function here
        if !validUserInformation() {return}

        //going to check if already exists
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        //read the data-> fetching will allow us to read
        if let existingUsers = try? context.fetch(fetchRequest), !existingUsers.isEmpty {
            message = "This email is already registered. Please try logging in."
            showAlert = true
            return
        }
        //going to use the core data model User the entity
        let newUser = User(context: context)
        //going to add the information now to the core data model
        newUser.id = UUID()
        newUser.email = email
        newUser.password = password
        
        //now save the context
        do {
            try context.save()
            message = "Account Created Successfully!"
            showAlert = true
        } catch {
            message = "Failed to create account. Please try again."
            showAlert = true
        }
        email = ""
        password = ""
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
            message: .constant(""),
            loginSuccess: { _ in }
        )
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
