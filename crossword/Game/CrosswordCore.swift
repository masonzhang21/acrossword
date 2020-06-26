//
//  CrosswordCore.swift
//  crossword
//
//  Created by Mason Zhang on 5/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class CrosswordCore {
    
    var state: CrosswordState
    var scheme: CrosswordScheme
    
    init(scheme: CrosswordScheme) {
        self.scheme = scheme
        
        let clueTracker = ClueTracker(scheme: scheme)
        let emptyInputRow: [Guess?] = Array(repeating: nil, count: scheme.numCols)
        var emptyInputGrid: [[Guess?]] = Array(repeating: emptyInputRow, count: scheme.numRows)
        let emptyBindingsRow: [TileState?] = Array(repeating: nil, count: scheme.numCols)
        var emptyBindingsGrid: [[TileState?]] = Array(repeating: emptyBindingsRow, count: scheme.numRows)
        for i in 0..<scheme.numRows {
            for j in 0..<scheme.numCols {
                if scheme.grid[i][j] != nil {
                    emptyInputGrid[i][j] = Guess()
                    emptyBindingsGrid[i][j] = TileState()
                }
            }
        }

        //giving dummy initializations to currentTile and currentWord lets us use the instance methods gridnumLoc and tilesInSameWord to compute the two properties. Doing it this way also calls their willSet observers, which wouldn't be the case if we initialized the values with the initializer.
        self.state = CrosswordState(clueTracker: clueTracker, initBindingsGrid: emptyBindingsGrid, initInputGrid: emptyInputGrid, initTile: TileLoc(row: 0, col: 0), initWord: [])
        let currentTile: TileLoc = gridnumLoc(of: 1)!
        let currentWord: [TileLoc] = tilesInSameWord(as: currentTile, dir: .across)
        self.state.focusedTile = currentTile
        self.state.currentTile = currentTile
        self.state.currentWord = currentWord
    }
    
    /**
     Returns the first empty tile in a list of tiles, or the first tile if all tiles are filled. Input is usually currentWord.
     */
    func firstEmptyTile(in word: [TileLoc]) -> TileLoc {
        for tile in word {
            if state.input[tile.row][tile.col]!.text == "" {
                return tile
            }
        }
        return word.first!
    }
    /**
     Returns all tiles in the same word as the lookup tile (including the lookup tile) in the order they appear in the word
     
     - Parameters:
     - lookupTile: The tile whose sibling tiles (tiles in the same word as it) we're searching for
     - dir: Direction for the search
     
     - Returns: An array of tuples corresponding to the locations of all tiles in the same word as the lookup tile
     */
    func tilesInSameWord(as lookupTile: TileLoc, dir: Direction) -> [TileLoc] {
        var tiles: [TileLoc] = []
        switch dir {
        case .across:
            let row = lookupTile.row
            var firstTileInWord: TileLoc = TileLoc(row: row, col: 0)
            for i in (0...lookupTile.col).reversed() {
                let ithTile = scheme.grid[row][i]
                if ithTile == nil {
                    firstTileInWord = TileLoc(row: row, col: i + 1)
                    break
                }
            }
            for i in firstTileInWord.col..<scheme.numCols {
                let ithTile = scheme.grid[row][i]
                if ithTile == nil {
                    break
                } else {
                    tiles.append(TileLoc(row: row, col: i))
                }
            }
        case .down:
            let col = lookupTile.col
            var firstTileInWord: TileLoc = TileLoc(row: 0, col: col)
            for i in (0...lookupTile.row).reversed() {
                let ithTile = scheme.grid[i][col]
                if ithTile == nil {
                    firstTileInWord = TileLoc(row: i + 1, col: col)
                    break
                }
            }
            for i in firstTileInWord.row..<scheme.numCols {
                let ithTile = scheme.grid[i][col]
                if ithTile == nil {
                    break
                } else {
                    tiles.append(TileLoc(row: i, col: col))
                }
            }
        }
        return tiles
    }
    
    /**
     Finds the location of the tile containing the specified gridnum
     
     - Parameters:
     - num: The gridnum
     
     - Returns: The TileLoc of the specified gridnum
     */
    func gridnumLoc(of num: Int) -> TileLoc? {
        for row in 0..<scheme.numRows {
            if let col = scheme.gridnums[row].firstIndex(of: num) {
                return TileLoc(row: row, col: col)
            }
        }
        return nil
    }
    
    
    func deactivateBoard() {
        state.focusedTile = nil
        state.active = false
    }
    
    func activateBoard() {
        state.focusedTile = state.currentTile
        state.active = true
    }
    
    /**
     Changes the direction in CrosswordState and recalculates the current word
     */
    func flipDirection() {
        switch state.direction {
        case .across:
            state.direction = .down
        case .down:
            state.direction = .across
        }
        state.currentWord = tilesInSameWord(as: state.currentTile, dir: state.direction)
    }
    
    /**
     Unfocuses all tiles and drops keyboard
     */
    func clearFocus() {
        
    }
    
    /**
     Changes focus to a certain tile
     
     Parameters:
     - loc: The tile to focus
     */
    func focus(tile: TileLoc) {
        state.focusedTile = tile
        state.currentWord = tilesInSameWord(as: tile, dir: state.direction)
    }
}
