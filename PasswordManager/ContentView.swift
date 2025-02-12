//
//  ContentView.swift
//  PasswordManager
//
//  Created by Christian Hernandez on 9/14/24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    //this data can only be within the contentView since it is a state(the parent view)
    @State private var isAuthenticated = false
    @State private var showAlert = false
    @State private var message = ""
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
                if(isAuthenticated) {
                    //TabView will allow me to organize the app content into multiple tabs. Each tab will represent a different screen/view, letting user switch between them by tapping on the corresponding tab bar icon or label
                    TabView {
                        //they can add password
                        AddPasswordView()
                        //the tabItem will create the icon of the tab view for user to switch from
                            .tabItem {
                                Image(systemName: "plus.circle")
                                Text("Add Password")
                                
                            }
                        //or look at their store passwords
                        StorePasswordsView()
                            .tabItem {
                                Image(systemName: "lock.fill")
                                Text("Stored Passwords")
                            }
                        SignOutView(isAuthenticated: $isAuthenticated)
                            .tabItem {
                                Image(systemName: "arrow.backward.circle")
                                Text("Sign Out")
                            }
                    }
                }
                else {
                    HomePageView(authenticatedPass: $isAuthenticated, showAlert: $showAlert, message: $message)
                }
            }
            
        }
        //this will appear each time the view pops up
        .onAppear {
            checkUserLoggedIn()
        }
        .animation(.easeInOut(duration: 0.5), value: showAnimation)
    }
    //this function will check if user is logged in if they are then they don't need to sign in
    private func checkUserLoggedIn() {
        if Auth.auth().currentUser != nil {
            isAuthenticated = true
        }
        else {
            isAuthenticated = false
        }
    }
}
//this will give the animation once you open the app
struct AnimationScreenView: View {
    var body: some View {
        //layered on top of another
        ZStack{
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            VStack {
                Image("animationimage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .padding(.top, -150)
                    .padding(.bottom, -70)
                Text("KodiCrew Mysterious")
                    .font(.largeTitle)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.white)
            }
        }
        //this will give it a transition once it is displayed
        .transition(.opacity)
    }
}
//sign out struct and pass it in the tabview
struct SignOutView: View {
    //binding will allow two way connection-> changes made here are going to be changed in the parent view
    @Binding var isAuthenticated: Bool
    @ObservedObject var authManager = AuthManager()
    
    var body: some View {
        VStack {
            Text("Are you sure you want to sign out?")
                .font(.headline)
                .padding()
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
