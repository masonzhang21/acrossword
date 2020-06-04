//
//  CrosswordState.swift
//  crossword
//
//  Created by Mason Zhang on 5/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SwiftUI

enum Direction {
    case across
    case down
}

struct CrosswordState {
    //only used for a couple of computed properties.
    //TO-DO: remove later to separate scheme & state?
    //DESIGN CHOICE: putting grid in CrosswordState is questionable?
    var scheme: CrosswordScheme
    var grid: [[TileState?]]

    var input: [[String?]] {
        didSet {
            let tile = grid[currentTile.row][currentTile.col]!
            tile.text = input[currentTile.row][currentTile.col]!
        }
    }
    var focusedTile: TileLoc? {
        willSet {
            //removes focus from previously focused element (if the focused tile changed or if an element was previously focused)
            if let prevLoc = focusedTile, newValue != focusedTile{
                let previouslyFocusedTile = grid[prevLoc.row][prevLoc.col]!
                previouslyFocusedTile.isFocused = false
            }
            //focuses the focusedTile and sets currentTile equal to focusedTile
            if let newLoc = newValue {
                currentTile = newLoc
                let tile = grid[newLoc.row][newLoc.col]!
                tile.isFocused = true
            }
        }
    }

var currentTile: TileLoc {
    willSet {
        //makes the current tile not the current tile anymore
        let curTile: TileState = grid[currentTile.row][currentTile.col]!
        curTile.isCurrentTile = false
        //makes the new tile the current tile
        let newTile: TileState = grid[newValue.row][newValue.col]!
        newTile.isCurrentTile = true
    }
}
var currentWord: [TileLoc] {
    willSet {
        for loc in currentWord {
            let tile: TileState = grid[loc.row][loc.col]!
            tile.isCurrentWord = false
        }
        for loc in newValue {
            let newTile: TileState = grid[loc.row][loc.col]!
            newTile.isCurrentWord = true
        }
    }
}
var multiplayerFocusedTiles: [TileLoc]?
var direction: Direction = .across
var rebusMode: Bool = false
var pencilMode: Bool = false
var active: Bool = true {
    didSet {
        if !active {
            focusedTile = nil
        }
    }
}

var clueNum: Int {
    get {
        return scheme.gridnums[currentWord.first!.row][currentWord.first!.col]!
    }
}

var clue: String {
    get {
        switch direction {
        case .across:
            return scheme.acrossClues[clueNum]!.clue
        case .down:
            return scheme.downClues[clueNum]!.clue
        }
    }
}


init(scheme: CrosswordScheme, initBindingsGrid: [[TileState?]], initInputGrid: [[String?]], initTile: TileLoc, initWord: [TileLoc]) {
    grid = initBindingsGrid
    currentTile = initTile
    currentWord = initWord
    input = initInputGrid
    self.scheme = scheme
    
}
}
