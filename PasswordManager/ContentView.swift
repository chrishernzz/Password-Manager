//
//  ContentView.swift
//  PasswordManager
//
//  Created by Christian Hernandez on 9/14/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var context
    //this data can only be within the contentView since it is a state(the parent view)
    @State private var isAuthenticated = false
    @State private var loggedInUser: User?
    @State private var homeViewStates: (showAlert: Bool, message: String) = (false, "")
    @State private var showAnimation = true
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            //since it is initialize to true it will run this which is the animation
            if (showAnimation) {
                AnimationScreenView()
                    //.transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                showAnimation = false
                            }
                        }
                    }
            }
            else {
                                    //going to unwrap the loggedInUser
                if(isAuthenticated), let user = loggedInUser {
                    //TabView will allow me to organize the app content into multiple tabs. Each tab will represent a different screen/view, letting user switch between them by tapping on the corresponding tab bar icon or label
                    TabView {
                        //they can add password
                        AddPasswordView(loggedInUser: user)
                        //the tabItem will create the icon of the tab view for user to switch from
                            .tabItem {
                                Image(systemName: "plus.circle")
                                Text("Add Password")
                                
                            }
                        //or look at their store passwords
                        StorePasswordsView(loggedInUser: user)
                            .tabItem {
                                Image(systemName: "lock.fill")
                                Text("Stored Passwords")
                            }
                        SignOutView(isAuthenticated: $isAuthenticated,resetInformation: {homeViewStates = (false, "")})
                            .tabItem {
                                Image(systemName: "arrow.backward.circle")
                                Text("Sign Out")
                            }
                    }
                    .environment(\.managedObjectContext, context)
                }
                else {
                    HomePageView(authenticatedPass: $isAuthenticated, showAlert: $homeViewStates.showAlert, message: $homeViewStates.message, loginSuccess: {user in loggedInUser = user})
                        .environment(\.managedObjectContext, context)
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.5), value: showAnimation)
    }
}
//this will give the animation once you open the app
struct AnimationScreenView: View {
    var body: some View {
        ZStack{
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            VStack {
                Image("animationimage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .padding(.top, -150)
                    .padding(.bottom, -70)
                Text("Double00 Mysterious")
                    .font(.largeTitle)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.white)
            }
        }
        .transition(.opacity)
    }
}
//sign out struct and pass it in the tabview
struct SignOutView: View {
    //binding will allow two way connection-> changes made here are going to be changed in the parent view
    @Binding var isAuthenticated: Bool
    //closure function to reste all the information
    var resetInformation: () -> Void
    var body: some View {
        VStack {
            Text("Are you sure you want to sign out?")
                .font(.headline)
                .padding()
            Button(action: {
                // Toggle isAuthenticated to false to log out
                isAuthenticated = false
                resetInformation()
            }) {
                Text("Sign Out")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}

//this will allow me to use the CRUD-> the data of the core data model 
struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "StoreInformation") // Replace with your Core Data model name
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
//extension is used for preview functionality
extension PersistenceController {
    static var preview: PersistenceController = {
        let controller = PersistenceController()
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSInMemoryStoreType // Use in-memory store for previews
        controller.container.persistentStoreDescriptions = [storeDescription]
        controller.container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return controller
    }()
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
