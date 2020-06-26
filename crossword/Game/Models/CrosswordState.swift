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

enum Font {
    case correct
    case incorrect
    case pencil
    case normal
}

//TO-DO: horrible name. GuessAndConfidence? Something?
struct Guess: Equatable {
    var text: String = ""
    var color: Font = .normal
}

class CrosswordState {
    var active: Bool = true {
        didSet {
            if active {
                focusedTile = currentTile
            } else {
                focusedTile = nil
            }
        }
    }
    //make a ClueMode wrapper for an OO and move clueMode logic there
    //var boardSwitch:
    var clueTracker: ClueTracker

    var tileBindings: [[TileState?]]
    
    var isMultiplayer: Bool = false
    var multiplayerFocusedTiles: [TileLoc]?
    var pencilMode: Bool = false
    var direction: Direction = .across
    //only change one at a time (no replacing rows/entire 2d array)
    var input: [[Guess?]] {
        didSet {
            var loc: TileLoc?
            for row in 0..<input.count {
                for col in 0..<input[row].count {
                    if input[row][col] != oldValue[row][col] {
                        loc = TileLoc(row: row, col: col)
                    }
                }
            }
            if let loc = loc {
                let tile = tileBindings[loc.row][loc.col]!
                tile.text = input[loc.row][loc.col]!.text
                tile.font = input[loc.row][loc.col]!.color
            }
        }
    }
    var focusedTile: TileLoc? {
        willSet {
            //removes focus from previously focused element (if the focused tile changed or if an element was previously focused)
            if let prevLoc = focusedTile, newValue != focusedTile{
                let previouslyFocusedTile = tileBindings[prevLoc.row][prevLoc.col]!
                previouslyFocusedTile.isFocused = false
            }
            //focuses the focusedTile and sets currentTile equal to focusedTile
            if let newLoc = newValue {
                currentTile = newLoc
                let tile = tileBindings[newLoc.row][newLoc.col]!
                tile.isFocused = true
            }
        }
    }
    var currentTile: TileLoc {
        willSet {
            //makes the current tile not the current tile anymore
            let curTile: TileState = tileBindings[currentTile.row][currentTile.col]!
            curTile.isCurrentTile = false
            //makes the new tile the current tile
            let newTile: TileState = tileBindings[newValue.row][newValue.col]!
            newTile.isCurrentTile = true
        }
    }
    var currentWord: [TileLoc] {
        willSet {
            for loc in currentWord {
                let tile: TileState = tileBindings[loc.row][loc.col]!
                tile.isCurrentWord = false
            }
            for loc in newValue {
                let newTile: TileState = tileBindings[loc.row][loc.col]!
                newTile.isCurrentWord = true
            }
        }
        didSet {
            clueTracker.updateClue(to: currentWord, direction: direction)
        }
    }

    init(clueTracker: ClueTracker, initBindingsGrid: [[TileState?]], initInputGrid: [[Guess?]], initTile: TileLoc, initWord: [TileLoc]) {
        tileBindings = initBindingsGrid
        currentTile = initTile
        currentWord = initWord
        input = initInputGrid
        self.clueTracker = clueTracker
    }
}
