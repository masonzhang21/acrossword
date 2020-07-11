//
//  AuthVM.swift
//  crossword
//
//  Created by Mason Zhang on 4/19/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase
import Combine

//Maybe this class should be split up into 3 different VMs for LoginView, ResetPasswordView, and SignupView. The class isn't really acting as a VM for any of them but instead a collection of methods relating to Firebase Auth, which I do like. But as of right now its methods are returning values which the Views use to update their state, instead of through bindings with each view. It also poses the question of where I store the User. I'd like to put it in AppData, which is the EnvironmentObject
class FirebaseAuth {
    
    func createAccount(email: String, username: String, password: String) -> String? {
        switch email.validate(rule: ValidationRules.email) {
        case .invalid(let error): return error.first?.message
        case .valid: break
        }
        switch username.validate(rules: ValidationRules.username) {
        case .invalid(let error): return error.first?.message
        case .valid: break
        }
        switch password.validate(rules: ValidationRules.password) {
        case .invalid(let error): return error.first?.message
        case .valid: break
        }
        
        var err: String?
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            guard error == nil else {
                err = "An account for this user already exists. Sign in?"
                return
            }
            Firestore.firestore().collection("users").document(result!.user.uid).setData([
                "email": email,
                "username": username
            ]) { error in if let error = error { err = error.localizedDescription }}
        }
        return err
    }
    
    func resetPassword(email: String) -> String? {
        switch email.validate(rule: ValidationRules.email) {
        case .invalid(let error): return error.first?.message
        case .valid: break
        }
        
        var response: String?
        Auth.auth().sendPasswordReset(withEmail: email) {error in
            if error == nil {
                response = "✔️ Success! Check your inbox."
            } else {
                response = "Email not found."
            }
        }
        return response
    }
    
    func getAuthStateChangeListener (appData: AppData) -> AuthStateDidChangeListenerHandle {
        // monitor authentication changes using firebase
        return Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                appData.user = User(
                    uid: user.uid,
                    email: user.email
                )
            } else {
                appData.user = nil
            }
        }
    }
    
    func signOut () {
        do {
            try Auth.auth().signOut()
        } catch {
            return
        }
    }
    

    
}

struct AuthVM_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
