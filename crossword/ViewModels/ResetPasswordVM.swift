//
//  ResetPasswordVM.swift
//  crossword
//
//  Created by Mason Zhang on 4/28/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase
import Combine

class ResetPasswordVM : ObservableObject {

    @Published var response: String?
    
    func resetPassword(email: String) -> Void {
        response = nil
        switch email.validate(rule: ValidationRules.email) {
        case .invalid(let error):
            response = error.first?.message
            return
        case .valid: break
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) {error in
            if error == nil {
                self.response = "✔️ Success! Check your inbox."
            } else {
                self.response = "Email not found."
            }
        }
    }
    
    func reset() -> Void {
        response = nil
    }
}
