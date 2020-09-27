//
//  ClueTracker.swift
//  crossword
//
//  Created by Mason Zhang on 6/13/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation

class ClueTracker: ObservableObject {
    @Published var clue: Clue
    var scheme: CrosswordScheme
    
    init(scheme: CrosswordScheme) {
        self.scheme = scheme
        clue = scheme.acrossClues[1]!
    }
    
    func updateClue(to currentWord: [TileLoc], direction: Direction) {
        let clueNum = scheme.gridnums[currentWord.first!.row][currentWord.first!.col]!
        switch direction {
        case .across:
            clue = scheme.acrossClues[clueNum]!
        case .down:
            clue = scheme.downClues[clueNum]!
        }
    }
}

class ModesTracker: ObservableObject {
    @Published var clueMode: Bool = false
    @Published var pencilMode: Bool = false
    @Published var multiplayerMode: Bool = false
    @Published var readyMode: Bool = false
    @Published var syncMode: Bool = false
    @Published var completedMode: Bool = false
    
}



