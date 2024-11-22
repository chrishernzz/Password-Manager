//
//  AddPasswordView.swift
//  PasswordManager
//
//  Created by Christian Hernandez on 9/14/24.
//

import Foundation
import SwiftUI

struct AddPasswordView: View{
    //able to use this between any structs since it is global and proivdes access to the NSManagedObjectContext. need this to use the CRUD in Core Data
    @Environment(\.managedObjectContext) var context
    //call the user entity
    var loggedInUser: User
    //since they are state, they can only be used within this strcuture
    @State private var title: String = ""
    @State private var emailOrusername: String = ""
    @State private var password: String = ""
    
    var body: some View{
        //this makes it into a group
        Form {
            Section(header: Text("Website Details")){
                TextField("Title",text: $title)
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .disableAutocorrection(true)
                TextField("Email or Username",text: $emailOrusername)
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .disableAutocorrection(true)
                SecureField("Password",text: $password)
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .disableAutocorrection(true)
            }
            Button(action: {
                //call the savePassword() function once the save password is access
                savePassword()
            }) {
                Text("Save Password")
                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/,maxWidth: .infinity)
                    .padding()
                    //if it is filled then print color green meaning it is correct
                    .background(informationFilled ? Color.green: Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            //disable the button if not filled so it wont let user to save the passwor
            .disabled(!informationFilled)
        }
    }
    
    //creating a check that returns if password is valid (computed properties)
    var informationFilled: Bool{
        //if they are not empty, then valid
        return !title.isEmpty && !emailOrusername.isEmpty && !password.isEmpty
    }
    //creating a function that saves all the passwords
    func savePassword(){    
        //if not empty then save the password
        if(informationFilled){
            //you now call the view-> PasswordManagerView that will allow us to use the addPassword function
            let passwordManager = PasswordManagerView(context: context)
            passwordManager.addPassword(for: loggedInUser, title: title, emailOrusername: emailOrusername, password: password)
            //clear the data enter after the password is save
            title = ""
            emailOrusername = ""
            password = ""
        }
    }
}
//function to keep track of the length and special characters and return a boolean
//func isPasswordValid(_ password: String) -> Bool {
//    let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>]).{6,}$"
//    //the predicates allow us to filter the result
//    let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
//    return passwordTest.evaluate(with: password)
//}

