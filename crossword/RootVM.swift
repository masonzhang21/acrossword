//
//  RootVM.swift
//  crossword
//
//  Created by Mason Zhang on 4/28/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase
import Combine

class RootVM {
    var handle: AuthStateDidChangeListenerHandle?
    
    func setAuthStateChangeListener(appData: AppData) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                appData.user = User(
                    uid: user.uid,
                    email: user.email
                )
                appData.changeView(view: ViewSelector.getView(.home))
                
            } else {
                appData.user = nil
                appData.changeView(view: ViewSelector.getView(.login))
            }
        }
    }
    
    func removeAuthStateChangeListener(appData: AppData) {
        if (handle != nil) {
            Auth.auth().removeStateDidChangeListener(handle!)
            appData.user = nil
        }
    }

}
