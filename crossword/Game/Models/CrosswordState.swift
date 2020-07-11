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

extension Font: Codable {
    enum Key: CodingKey {
        case rawValue
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            self = .correct
        case 1:
            self = .incorrect
        case 2:
            self = .pencil
        case 3:
            self = .normal
        default:
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .correct:
            try container.encode(0, forKey: .rawValue)
        case .incorrect:
            try container.encode(1, forKey: .rawValue)
        case .pencil:
            try container.encode(2, forKey: .rawValue)
        case .normal:
            try container.encode(3, forKey: .rawValue)

        }
    }
}

//TO-DO: horrible name. GuessAndConfidence? Something?
struct Guess: Equatable, Codable {
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
    var input: [[Guess?]] {
        didSet {
            var changes: [TileLoc] = []
            //computationally inefficient...replace with method that takes in (TileLoc, Guess)? profile...
            for row in 0..<input.count {
                for col in 0..<input[row].count {
                    if input[row][col] != oldValue[row][col] {
                        changes.append(TileLoc(row: row, col: col))
                    }
                }
            }
            for changed in changes {
                let tile = tileBindings[changed.row][changed.col]!
                tile.text = input[changed.row][changed.col]!.text
                tile.font = input[changed.row][changed.col]!.color
            }
            lastEdit = Int(NSDate().timeIntervalSince1970)
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
    
    var lastEdit: Int

    init(clueTracker: ClueTracker, initBindingsGrid: [[TileState?]], initInputGrid: [[Guess?]], initTile: TileLoc, initWord: [TileLoc]) {
        self.clueTracker = clueTracker
        tileBindings = initBindingsGrid
        input = initInputGrid
        currentTile = initTile
        currentWord = initWord
        lastEdit = Int(NSDate().timeIntervalSince1970)

        defer {
            input = initInputGrid
            currentTile = initTile
            currentWord = initWord
        }
    }
}
