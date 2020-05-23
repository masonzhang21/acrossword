//
//  CrosswordVM.swift
//  crossword
//
//  Created by Mason Zhang on 5/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class CrosswordVM: ObservableObject {
    
    @Published var state: CrosswordState
    let scheme: CrosswordScheme
    
    init(scheme: CrosswordScheme) {
        self.scheme = scheme
        
        let emptyRow: [String?] = Array(repeating: "", count: scheme.numCols)
        var emptyGrid: [[String?]] = Array(repeating: emptyRow, count: scheme.numRows)
        for i in 0..<scheme.numRows {
            for j in 0..<scheme.numCols {
                if scheme.grid[i][j] == nil {
                    emptyGrid[i][j] = nil
                }
            }
        }
        //quick fix: initialize state with only emptyGrid and reinitialize it later
        self.state = CrosswordState(initGrid: emptyGrid)
        
        let focusedTile: TileLoc = gridnumLoc(of: 1)!
        let focusedWord: [TileLoc] = tilesInSameWord(as: focusedTile, dir: .across)
        self.state = CrosswordState(initTile: focusedTile, initWord: focusedWord, initGrid: emptyGrid)
    }
    
    /**
     Returns all tiles in the same word as the lookup tile (including the lookup tile) in the order they appear in the word
     
     - Parameters:
     - tile: The tile whose sibling tiles (tiles in the same word as it) we're searching for
     - direction: Direction for the search
     
     - Returns: An array of tuples corresponding to the locations of all tiles in the same word as the lookup tile
     */
    func tilesInSameWord(as lookupTile: TileLoc, dir: Direction) -> [TileLoc] {
        var tiles: [TileLoc] = []
        switch dir {
        case .across:
            let row = lookupTile.row
            var firstTileInWord: TileLoc = TileLoc(row: row, col: 0)
            for i in lookupTile.col...0 {
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
            for i in lookupTile.row...0 {
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
     
     -Parameters:
     -num: The gridnum
     
     -Returns: The TileLoc of the specified gridnum
     */
    func gridnumLoc(of num: Int) -> TileLoc? {
        for row in 0..<scheme.numRows {
            if let col = scheme.gridnums[row].firstIndex(of: num) {
                return TileLoc(row: row, col: col)
            }
        }
        return nil
    }
    
    /**
     Changes the direction in CrosswordState
     */
    func flipDirection() {
        switch state.direction {
        case .across:
            state.direction = .down
        case .down:
            state.direction = .across
        }
    }
    
    /**
     Unfocuses all tiles and drops keyboard
     */
    func clearFocus() {
        state.focusedTile = nil
    }
    
    /**
     Changes focus to the first empty tile in the next word with an empty tile
     */
    func focusNextWord() {
        
        func searchAcrossClues(from start: Int) -> Bool{
            let acrossClueNums: [Int] = Array(scheme.acrossClues.keys).sorted(by: <)
            let startIndex = acrossClueNums.firstIndex(of: start)!
            let slice = acrossClueNums[startIndex..<acrossClueNums.count]
            for cluenum in slice {
                let clue: Clue = scheme.acrossClues[cluenum]!
                let clueTiles = tilesInSameWord(as: clue.firstTile, dir: .across)
                for tile in clueTiles {
                    if state.inputGrid[tile.row][tile.col]! == "" {
                        state.focusedTile = tile
                        state.currentWord = clueTiles
                        return true
                    }
                }
            }
            return false
        }
        func searchDownClues(from start: Int) -> Bool {
            let downClueNums: [Int] = Array(scheme.downClues.keys).sorted(by: <)
            let startIndex = downClueNums.firstIndex(of: start)!
            let slice = downClueNums[startIndex..<downClueNums.count]
            for cluenum in slice {
                let clue: Clue = scheme.downClues[cluenum]!
                let clueTiles = tilesInSameWord(as: clue.firstTile, dir: .down)
                for tile in clueTiles {
                    if state.inputGrid[tile.row][tile.col]! == "" {
                        state.focusedTile = tile
                        state.currentWord = clueTiles
                        return true
                    }
                }
            }
            return false
        }
        
        guard let currentWord: [TileLoc] = state.currentWord else {
            return
        }
        let currentClueNum: Int = scheme.gridnums[currentWord[0].row][currentWord[0].col]!
        switch state.direction {
        case .across:
            if !searchAcrossClues(from: currentClueNum) {
                //none of the across clues after the current clue had an empty space, so we need to wrap around the board and change direction to down
                state.direction = .down
                searchDownClues(from: 0)
            }
        case .down:
            if !searchAcrossClues(from: currentClueNum) {
                //none of the down clues after the current clue had an empty space, so we need to wrap around the board and change direction to across
                state.direction = .across
                searchAcrossClues(from: 0)
            }
        }
    }
    
    /**
     Changes focus to the next tile
     */
    func focusNext(wasEmpty skipFilledTiles: Bool) {
        let fCol = state.focusedTile!.col
        let fRow = state.focusedTile!.row
        
        switch (state.direction, skipFilledTiles) {
        case (.across, true):
            colLoop: for i in fCol..<scheme.numCols {
                switch state.inputGrid[fRow][i] {
                case "":
                    state.focusedTile = TileLoc(row: fRow, col: i)
                    break colLoop
                case nil:
                    self.focusNextWord()
                    break colLoop
                default:
                    continue
                }
            }
        case (.across, false):
            if fCol < scheme.numCols && scheme.grid[fRow][fCol + 1] != nil {
                state.focusedTile = TileLoc(row: fRow, col: fCol + 1)
            } else {
                self.focusNextWord()
            }
        case (.down, true):
            colLoop: for i in fRow..<scheme.numRows {
                switch state.inputGrid[i][fCol] {
                case "":
                    state.focusedTile = TileLoc(row: i, col: fCol)
                    break colLoop
                case nil:
                    self.focusNextWord()
                    break colLoop
                default:
                    continue
                }
            }
        case (.down, false):
            if fRow < scheme.numRows && scheme.grid[fRow + 1][fCol] != nil {
                state.focusedTile = TileLoc(row: fRow + 1, col: fCol)
            } else {
                self.focusNextWord()
            }
            
        }
        
    }
    
    /**
     Changes focus to the previous tile
     */
    func focusPrev() {
        
    }
    
    
    
    /**
     Changes focus to the first empty tile in the previous word with an empty tile
     */
    func focusPrevWord() {
        
    }
    
    /**
     Changes focus to a certain tile
     
     Parameters:
     - loc: The tile to focus
     */
    func focus(loc: TileLoc) {
        state.focusedTile = loc
    }
}
