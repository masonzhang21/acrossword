//
//  BoardVM.swift
//  crossword
//
//  Created by Mason Zhang on 5/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class BoardActions {
    
    var core: CrosswordCore
    var state: CrosswordState
    var scheme: CrosswordScheme
    init(core: CrosswordCore) {
        self.core = core
        self.state = core.state
        self.scheme = core.scheme
    }
    
    /**
     Changes focus to the first empty tile in the next word with an empty tile. If focus is on the last across word, focus changes to the first empty tile of the first down tile with an empty tile and v/v.
     */
    @objc func nextWord() {
        /**
         Attempts to shift focus to the first across clue with an empty tile and a number greater than start. If successful, return true. If not successful (i.e. no across clue after the start(th) clue has an empty tile), return false.
         
         - Parameter start: Only clues from the start clue onwards will be considered. For example, if start=5, empty tiles in 3-across will be ignored.
         */
        func nextEmptyAcrossClue(from start: Int) -> Bool{
            let acrossClueNums: [Int] = Array(core.scheme.acrossClues.keys).sorted(by: <)
            let startIndex = (start == 0) ? 0 : (acrossClueNums.firstIndex(of: start)! + 1)
            //ex: if acrossClueNums was [1, 2, 3, 5, 8] and start was 3, slice would be [5, 8]
            //if start is 0, slice = acrossClueNums (and so all clues are 'considered')
            let slice = acrossClueNums[startIndex..<acrossClueNums.count]
            for cluenum in slice {
                let clue: Clue = scheme.acrossClues[cluenum]!
                let clueTiles = core.tilesInSameWord(as: clue.firstTile, dir: .across)
                for tile in clueTiles {
                    if state.input[tile.row][tile.col]!.text == "" {
                        core.updateFocusedTile(to: tile)
                        core.updateCurrentWord(to: clueTiles)
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
            let startIndex = (start == 0) ? 0 : (downClueNums.firstIndex(of: start)! + 1)
            let slice = downClueNums[startIndex..<downClueNums.count]
            for cluenum in slice {
                let clue: Clue = scheme.downClues[cluenum]!
                let clueTiles = core.tilesInSameWord(as: clue.firstTile, dir: .down)
                for tile in clueTiles {
                    if state.input[tile.row][tile.col]!.text == "" {
                        core.updateFocusedTile(to: tile)
                        core.updateCurrentWord(to: clueTiles)
                        return true
                    }
                }
            }
            return false
        }
        
        
        let currentClueNum: Int = state.clueTracker.clue.num
        switch state.direction {
        case .across:
            if !nextEmptyAcrossClue(from: currentClueNum) {
                //none of the across clues after the current clue had an empty space, so we need to wrap around the board and change direction to down
                state.direction = .down
                if !nextEmptyDownClue(from: 0) {
                    state.direction = .across
                    //TO-DO: all spaces have been filled in, check puzzle
                }
            }
        case .down:
            if !nextEmptyDownClue(from: currentClueNum) {
                //none of the down clues after the current clue had an empty space, so we need to wrap around the board and change direction to across
                state.direction = .across
                if !nextEmptyAcrossClue(from: 0) {
                    state.direction = .down
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
        let word = state.currentWord
        let isLastTileInWord: Bool = state.currentWord.last == state.focusedTile!
        
        if isLastTileInWord {
            nextWord()
        } else if skipFilledTiles{
            //finds index of next empty tile in the current word
            let wordEntries: [String] = word.map() {tile in
                state.input[tile.row][tile.col]!.text
            }
            let focusedIndex: Int = word.firstIndex(of: focused)!
            let nextEmptyTileIndex: Int? = wordEntries[(focusedIndex + 1)...].firstIndex(of: "")
            //if an empty tile in the current word exists, focus it
            if let index = nextEmptyTileIndex {
                core.updateFocusedTile(to: word[index])
            } else {
                nextWord()
            }
        } else if !skipFilledTiles{
            //if we don't want to skip filled tiles, increment row/col by 1.
            switch state.direction {
            case .across:
                core.updateFocusedTile(to: TileLoc(row: focused.row, col: focused.col + 1))
            case .down:
                core.updateFocusedTile(to: TileLoc(row: focused.row + 1, col: focused.col))
            }
        }
    }
    
    /**
     Changes focus to the previous tile and empties it
     */
    func prevTile() {
        let focused = state.focusedTile!
        let isFirstTileInWord: Bool = state.currentWord.first == focused
        
        if isFirstTileInWord {
            prevWord()
        } else {
            switch state.direction {
            case .across:
                let leftOfFocused = TileLoc(row: focused.row, col: focused.col - 1)
                core.updateFocusedTile(to: leftOfFocused)
                core.updateInput(at: leftOfFocused, to: TileInput(text: "", font: .normal))
            case .down:
                let northOfFocused = TileLoc(row: focused.row - 1, col: focused.col)
                core.updateFocusedTile(to: northOfFocused)
                core.updateInput(at: northOfFocused, to: TileInput(text: "", font: .normal))
                
            }
        }
    }
    
    
    /**
     Changes focus to the last tile in the previous word and empties it. If the current tile is the first tile (with gridnum 1), changes focus to the last tile of the last across/down word.
     */
    @objc func prevWord() {
        let curNum: Int = state.clueTracker.clue.num
        let newNum: Int
        let prevWord: [TileLoc]
        //figures out which word to focus
        switch state.direction {
        case .across:
            if curNum == 1 {
                //focus last down word
                newNum = scheme.downClueNums.last!
                state.direction = .down
                prevWord = core.tilesInSameWord(as: core.gridnumLoc(of: newNum)!, dir: .down)
            } else {
                //focus previous across word
                let index = scheme.acrossClueNums.firstIndex(of: curNum)! - 1
                newNum = scheme.acrossClueNums[index]
                prevWord = core.tilesInSameWord(as: core.gridnumLoc(of: newNum)!, dir: .across)
            }
        case .down:
            if curNum == 1 {
                newNum = scheme.acrossClueNums.last!
                state.direction = .across
                prevWord = core.tilesInSameWord(as: core.gridnumLoc(of: newNum)!, dir: .across)
            } else {
                let index = scheme.downClueNums.firstIndex(of: curNum)! - 1
                newNum = scheme.downClueNums[index]
                prevWord = core.tilesInSameWord(as: core.gridnumLoc(of: newNum)!, dir: .down
                )
            }
        }
        core.updateCurrentWord(to: prevWord)
        core.updateFocusedTile(to: prevWord.last!)
        core.updateInput(at: prevWord.last!, to: TileInput(text: "", font: .normal))

    }
}
