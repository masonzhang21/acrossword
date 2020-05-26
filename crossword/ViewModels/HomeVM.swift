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
    
    //TO-DO: Rename method, don't force crash if initialization fails (instead do nothing or display error message)
    func parse() -> CrosswordScheme {
        do {
            let c = try CrosswordScheme(id: "https://github.com/doshea/nyt_crosswords/blob/master/1976/03/03.json")!
            return c
        } catch {
           fatalError()
        }
    }
}

