//
//  SignUpVM.swift
//  crossword
//
//  Created by Mason Zhang on 4/28/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase
import Combine

class SignUpVM : ObservableObject {
    
    @Published var response: String?
    @Published var loading: Bool = false
    
    /**
    Attempts to create a user account.

    - Parameters:
        - email: User email.
        - username: User username
        - password: Password
     
     - Returns: nothing
    */
    func createAccount(email: String, username: String, password: String) -> Void {
        response = nil
        loading = true
        switch email.validate(rule: ValidationRules.email) {
        case .invalid(let error):
            response = error.first?.message
            loading = false
            return
        case .valid: break
        }
        switch username.validate(rules: ValidationRules.username) {
        case .invalid(let error):
            response = error.first?.message
            loading = false
            return
        case .valid: break
        }
        switch password.validate(rules: ValidationRules.password) {
        case .invalid(let error):
            response = error.first?.message
            loading = false
            return
        case .valid: break
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            guard error == nil else {
                self.response = "An account for this user already exists. Sign in?"
                self.loading = false
                return
            }
            
            Firestore.firestore().collection("users").document(result!.user.uid).setData([
                "email": email,
                "username": username
            ]) {error in
                if let error = error {
                    self.response = error.localizedDescription
                }
            }
        }
    }
    
    func reset() -> Void {
        response = nil
    }
}
