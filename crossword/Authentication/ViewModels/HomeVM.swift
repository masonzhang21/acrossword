//
//  HomeVM.swift
//  crossword
//
//  Created by Mason Zhang on 4/28/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

class HomeVM: ObservableObject {
    
    func signOut () {
        do {
            try Auth.auth().signOut()
        } catch {
            return
        }
    }
}

