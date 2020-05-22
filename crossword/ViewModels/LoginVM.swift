//
//  LoginVM.swift
//  crossword
//
//  Created by Mason Zhang on 4/28/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase
import Combine

class LoginVM: ObservableObject {
    @Published var response: String?
    @Published var loading: Bool = false
    
    func signInUser (email: String, password: String) -> Void {
        response = nil
        loading = true
        switch email.validate(rule: ValidationRules.email) {
        case .invalid(let error):
            loading = false
            response = error.first?.message
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
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            self.loading = false
            guard error == nil else {
                self.response = "Incorrect email/password."
                return
            }
        }
    }
}
