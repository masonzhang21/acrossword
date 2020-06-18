//
//  ClueTracker.swift
//  crossword
//
//  Created by Mason Zhang on 6/13/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
class ClueTracker: ObservableObject {
    @Published var clueNum: Int
    @Published var clue: String
    var scheme: CrosswordScheme
    
    init(scheme: CrosswordScheme) {
        self.scheme = scheme
        clueNum = 1
        clue = scheme.acrossClues[1]!.clue
    }
    
    func updateClue(to currentWord: [TileLoc], direction: Direction) {
        clueNum = scheme.gridnums[currentWord.first!.row][currentWord.first!.col]!
        switch direction {
        case .across:
            clue = scheme.acrossClues[clueNum]!.clue
        case .down:
            clue = scheme.downClues[clueNum]!.clue
        }
    }
}
