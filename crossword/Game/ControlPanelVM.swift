//
//  ControlPanelVM.swift
//  crossword
//
//  Created by Mason Zhang on 5/27/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class ControlPanelVM: ObservableObject {
    
    @Binding var state: CrosswordState
    @EnvironmentObject var appData: AppData
    @Published var displayCheckDropdown: Bool = false
    @Published var displayRevealDropdown: Bool = false

    init(state: Binding<CrosswordState>) {
        self._state = state
    }
    
    func displayClues() {
        
    }
    
    func switchWritingMode() {
        
    }
    
    func checkTile() {
        
    }
    
    func checkWord() {
        
    }
    
    func revealTile() {
        
    }
    
    func revealWord() {
        
    }
    
    func addFriends() {
        
    }
    
    func displayInfo() {
        
    }
    
    func displaySettings() {
        
    }
    
    
    
}
