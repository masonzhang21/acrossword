//
//  CrosswordState.swift
//  crossword
//
//  Created by Mason Zhang on 5/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation

enum Direction {
    case across
    case down
}

struct CrosswordState {
    //only used for a couple of computed properties.
    //TO-DO: remove later to separate scheme & state?
    var scheme: CrosswordScheme
    var inputGrid: [[String?]]

    var focusedTile: TileLoc?
    var multiplayerFocusedTiles: [TileLoc]?
    var currentWord: [TileLoc]?
    var direction: Direction = .across
    var rebus: Bool = false
    var pencilMode: Bool = false
    
    var clueNum: Int? {
        get {
            if let curWord = currentWord {
                return scheme.gridnums[curWord.first!.row][curWord.first!.col]
            } else {
                return nil
            }
        }
    }
    
    var clue: String? {
        get {
            guard let clueNum = clueNum else {
                return nil
            }
            switch direction {
            case .across:
                return scheme.acrossClues[clueNum]!.clue
            case .down:
                return scheme.downClues[clueNum]!.clue
            }
        }
    }
    
    init(initGrid: [[String?]], scheme: CrosswordScheme) {
        inputGrid = initGrid
        self.scheme = scheme
    }
    
    init(initTile: TileLoc, initWord: [TileLoc], initGrid: [[String?]], scheme: CrosswordScheme) {
        focusedTile = initTile
        currentWord = initWord
        inputGrid = initGrid
        self.scheme = scheme
        
    }
}
