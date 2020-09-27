//
//  CrosswordState.swift
//  crossword
//
//  Created by Mason Zhang on 5/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SwiftUI
import SocketIO
enum Direction {
    case across
    case down
}

class CrosswordState {
    let solutionGrid: [[String?]]
    var tileBindings: [[TileState?]]
    var clueTracker: ClueTracker
    var modes: ModesTracker
    var direction: Direction = .across
    var lastEdit: Int
    var players: [String: Player] = [:]
    
    var active: Bool = true {
        willSet {
            if newValue {
                focusedTile = currentTile
            } else {
                focusedTile = nil
            }
        }
    }
    var input: [[TileInput?]] {
        didSet {
            var changes: [TileLoc] = []
            //computationally inefficient...replace with method that takes in (TileLoc, Guess)? profile...
            var isCorrectAndCompleted = true
            for row in 0..<input.count {
                for col in 0..<input[row].count {
                    if input[row][col] != oldValue[row][col] {
                        changes.append(TileLoc(row: row, col: col))
                    }
                    if input[row][col]?.text != solutionGrid[row][col] {
                        isCorrectAndCompleted = false
                    }
                }
            }
            for changed in changes {
                let tile = tileBindings[changed.row][changed.col]!
                tile.text = input[changed.row][changed.col]!.text
                tile.font = input[changed.row][changed.col]!.font
            }
            if isCorrectAndCompleted {
                modes.completedMode = true
            }
            lastEdit = Int(NSDate().timeIntervalSince1970)
        }
    }
    var focusedTile: TileLoc? {
        willSet {
            //removes focus from previously focused element (if the focused tile changed or if an element was previously focused)
            if let prevTile = focusedTile, newValue != prevTile {
                let previouslyFocusedTile = tileBindings[prevTile.row][prevTile.col]!
                previouslyFocusedTile.isFocused = false
            }
            
            //focuses the focusedTile and sets currentTile equal to focusedTile
            if let newTile = newValue {
                currentTile = newTile
                let tile = tileBindings[newTile.row][newTile.col]!
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
    
    init(scheme: CrosswordScheme, initBindingsGrid: [[TileState?]], initInputGrid: [[TileInput?]], initTile: TileLoc, initWord: [TileLoc]) {
        solutionGrid = scheme.grid
        clueTracker = ClueTracker(scheme: scheme)
        modes = ModesTracker()
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

extension CrosswordState {
    
    func addPlayer(playerInfo: [String: Any]) {
        let rawTile = playerInfo["tileLoc"] as! [String: Int]
        let rawWord = playerInfo["wordLoc"] as! [[String: Int]]
        let color: UIColor = UIColor(hexaRGBA: playerInfo["color"] as! String)!
        let newPlayer = Player(username: playerInfo["playerID"] as! String, color: color, currentTile: TileLoc(location: rawTile), currentWord: rawWord.map {tile in TileLoc(location: tile)})
        players[newPlayer.username] = newPlayer
    }
    func setActive(tile: TileLoc, for playerID: String) {
        let prevTile = players[playerID]!.currentTile
        if let playerToRemoveIndex = tileBindings[prevTile.row][prevTile.col]!.playersOnTile.firstIndex(where: {$0.username == playerID}) {
            tileBindings[prevTile.row][prevTile.col]!.playersOnTile.remove(at: playerToRemoveIndex)
        }
        players[playerID]!.currentTile = tile
        tileBindings[tile.row][tile.col]!.playersOnTile.append(players[playerID]!)
    }
    
    func setActive(word: [TileLoc], for playerID: String) {
        let prevWord = players[playerID]!.currentWord
        
        for tile in prevWord {
            if let playerToRemoveIndex = tileBindings[tile.row][tile.col]!.playersOnWord.firstIndex(where: {$0.username == playerID}) {
                tileBindings[tile.row][tile.col]!.playersOnWord.remove(at: playerToRemoveIndex)
            }
        }
        players[playerID]!.currentWord = word

        for tile in word {
            tileBindings[tile.row][tile.col]!.playersOnWord.append(players[playerID]!)
        }
    }
    
    func removePlayer(playerID: String) {
        let curTile = players[playerID]!.currentTile
        let curWord = players[playerID]!.currentWord
        if let playerToRemoveIndex = tileBindings[curTile.row][curTile.col]!.playersOnTile.firstIndex(where: {$0.username == playerID}) {
            tileBindings[curTile.row][curTile.col]!.playersOnTile.remove(at: playerToRemoveIndex)
        }
        for tile in curWord {
            if let playerToRemoveIndex = tileBindings[tile.row][tile.col]!.playersOnWord.firstIndex(where: {$0.username == playerID}) {
                tileBindings[tile.row][tile.col]!.playersOnWord.remove(at: playerToRemoveIndex)
            }
        }
        players.removeValue(forKey: playerID)
    }
    
}
