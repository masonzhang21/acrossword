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

class CrosswordState {
    var focusedTile: TileLoc?
    var multiplayerFocusedTiles: [TileLoc]?
    var currentWord: [TileLoc]?
    var inputGrid: [[String?]]
    var direction: Direction = .across
    
    init(initGrid: [[String?]]) {
        inputGrid = initGrid
    }
    
    init(initTile: TileLoc, initWord: [TileLoc], initGrid: [[String?]]) {
        focusedTile = initTile
        currentWord = initWord
        inputGrid = initGrid
    }
}
