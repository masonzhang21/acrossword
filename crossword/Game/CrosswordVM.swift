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
    var scheme: CrosswordScheme
    
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

        self.state = CrosswordState(initGrid: emptyGrid, scheme: scheme)
        let focusedTile: TileLoc = gridnumLoc(of: 1)!
        let focusedWord: [TileLoc] = tilesInSameWord(as: focusedTile, dir: .across)
        self.state.focusedTile = focusedTile
        self.state.currentWord = focusedWord
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
        state.currentWord = tilesInSameWord(as: state.focusedTile!, dir: state.direction)
    }
    
    /**
     Unfocuses all tiles and drops keyboard
     */
    func clearFocus() {
        state.focusedTile = nil
    }
    
    /**
     Changes focus to the first empty tile in the next word with an empty tile. If focus is on the last across word, focus changes to the first empty tile of the first down tile with an empty tile and v/v.
     */
    func nextWord() {
        /**
         Attempts to shift focus to the frist across clue with an empty tile and a number greater than start. If successful, return true. If not successful (i.e. no across clue after the start(th) clue has an empty tile), return false.
         
         - Parameter start: Only clues from the start clue onwards will be considered. For example, if start=5, empty tiles in 3-across will be ignored.
         */
        func nextEmptyAcrossClue(from start: Int) -> Bool{
            let acrossClueNums: [Int] = Array(scheme.acrossClues.keys).sorted(by: <)
            let startIndex = acrossClueNums.firstIndex(of: start) ?? -1 + 1
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
        /**
         Attempts to shift focus to the first down clue with an empty tile and a number greater than start. If successful, return true. If not successful (i.e. no across clue after the start(th) clue has an empty tile) , return false.
         
         - Parameter start: Only clues from the start clue onwards will be considered. For example, if start=5, empty tiles in 3-down will be ignored.
         */
        func nextEmptyDownClue(from start: Int) -> Bool {
            let downClueNums: [Int] = Array(scheme.downClues.keys).sorted(by: <)
            let startIndex = downClueNums.firstIndex(of: start) ?? -1 + 1
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
            if !nextEmptyAcrossClue(from: currentClueNum) {
                //none of the across clues after the current clue had an empty space, so we need to wrap around the board and change direction to down
                state.direction = .down
                if !nextEmptyDownClue(from: 0) {
                    //TO-DO: all spaces have been filled in, check puzzle
                }
            }
        case .down:
            if !nextEmptyDownClue(from: currentClueNum) {
                //none of the down clues after the current clue had an empty space, so we need to wrap around the board and change direction to across
                state.direction = .across
                if !nextEmptyAcrossClue(from: 0) {
                    //TO-DO: all spaces have been filled in, check puzzle
                }
            }
        }
    }
    
    /**
     Changes focus to the next tile. This method is meant to be called by the currently focused tile and so it assumes that a tile/word is focused. Use focus(tile:) to focus an arbitrary tile.
     
     - Parameter skipFilledTiles Whether or not to focus the next empty tile or the next tile. If set to false, focus will be shifted to the next tile in the word (or if focus is currently on the last tile of the word, the next empty tile in the next word).
     */
    func nextTile(wasEmpty skipFilledTiles: Bool) {
        let focused = state.focusedTile!
        let word = state.currentWord!
        let isLastTileInWord: Bool = state.currentWord!.last == state.focusedTile
        
        if isLastTileInWord {
            nextWord()
        } else if skipFilledTiles{
            //finds index of next empty tile in the current word
            let wordEntries: [String] = word.map() {tile in
                state.inputGrid[tile.row][tile.col]!
            }
            let focusedIndex: Int = word.firstIndex(of: focused)!
            let nextEmptyTileIndex: Int? = wordEntries[(focusedIndex + 1)...].firstIndex(of: "")
            //if an empty tile in the current word exists, focus it
            if let index = nextEmptyTileIndex {
                state.focusedTile = word[index]
            } else {
                nextWord()
            }
        } else {
            //if we don't want to skip filled tiles, increment row/col by 1.
            switch state.direction {
            case .across:
                state.focusedTile = TileLoc(row: focused.row, col: focused.col + 1)
            case .down:
                state.focusedTile = TileLoc(row: focused.row + 1, col: focused.col)
            }
        }
    }
    
    /**
     Changes focus to the previous tile and empties it
     */
    func prevTile() {
        let focused = state.focusedTile!
        let isFirstTileInWord: Bool = state.currentWord!.first == focused
        
        if isFirstTileInWord {
            prevWord()
        } else {
            switch state.direction {
            case .across:
                state.focusedTile = TileLoc(row: focused.row, col: focused.col - 1)
                state.inputGrid[focused.row][focused.col - 1] = ""
            case .down:
                state.focusedTile = TileLoc(row: focused.row - 1, col: focused.col)
                state.inputGrid[focused.row - 1][focused.col] = ""

                
            }
        }
    }
    
    
    
    /**
     Changes focus to the last tile in the previous word and empties it. If the current tile is the first tile (with gridnum 1), changes focus to the last tile of the last across/down word.
     */
    func prevWord() {
        let curNum: Int = state.clueNum!
        let newNum: Int
        switch state.direction {
        case .across:
            if curNum == 1 {
                state.direction = .down

                newNum = scheme.downClueNums.last!
                state.currentWord = tilesInSameWord(as: self.gridnumLoc(of: newNum)!
                    , dir: .down)
            } else {
                let index = scheme.acrossClueNums.firstIndex(of: curNum)! - 1
                newNum = scheme.acrossClueNums[index]
                state.direction = .across
                state.currentWord = tilesInSameWord(as: self.gridnumLoc(of: newNum)!
                    , dir: .across)
            }
            state.focusedTile = state.currentWord!.last
            state.inputGrid[state.focusedTile!.row][state.focusedTile!.col] = ""
        case .down:
            if curNum == 1 {
                state.direction = .across

                newNum = scheme.acrossClueNums.last!
                state.currentWord = tilesInSameWord(as: self.gridnumLoc(of: newNum)!, dir: .across)
            } else {
                let index = scheme.downClueNums.firstIndex(of: curNum)! - 1
                newNum = scheme.downClueNums[index]
                state.direction = .down
                state.currentWord = tilesInSameWord(as: self.gridnumLoc(of: newNum)!, dir: .down)
            }
            state.focusedTile = state.currentWord!.last
            state.inputGrid[state.focusedTile!.row][state.focusedTile!.col] = ""
        }
        
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
