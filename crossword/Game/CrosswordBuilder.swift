//
//  CrosswordBuilder.swift
//  crossword
//
//  Created by Mason Zhang on 7/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SwiftyJSON
class CrosswordBuilder {
    
    static func buildCrosswordScheme(for id: CrosswordID) -> CrosswordScheme {
        return CrosswordScheme(json: CrosswordIO.retrieveJSONFromDisk(id: id)!)
    }
    
//    static func buildCrosswordState(for id: CrosswordID, user: User) -> CrosswordState {
//        //since state is a reference property: editing state should change it later too
//        var state = newCrosswordState(from: buildCrosswordScheme(for: id))
//
//        if let stored = CrosswordIO.retrieveCrosswordState(user: user, id: id) {
//            return buildCrosswordState(from: stored)
//        } else {
//            return newCrosswordState(from: buildCrosswordScheme(for: id))
//        }
//    }
    
    static func buildCrosswordState(from stored: StoredCrossword) -> CrosswordState {
        var inputGrid: [[Guess?]] = Array(repeating: [], count: stored.input.count)
        for (index, row) in stored.input {
            inputGrid[index] = row
        }
        let state = newCrosswordState(from: buildCrosswordScheme(for: stored.id))
        state.input = inputGrid
        return state
    }
    
    static func newCrosswordState(from scheme: CrosswordScheme) -> CrosswordState {
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
        var initTile: TileLoc!
        //sets initTile to the tile with gridnum 1
        for row in 0..<scheme.numRows {
            if let col = scheme.gridnums[row].firstIndex(of: 1) {
                initTile = TileLoc(row: row, col: col)
                break
            }
        }
        var initWord: [TileLoc] = []
        //sets initWord to the across word containing the tile with gridnum 1
        for i in initTile.col..<scheme.numCols {
            let ithTile = scheme.grid[initTile.row][i]
            if ithTile == nil {
                break
            } else {
                initWord.append(TileLoc(row: initTile.row, col: i))
            }
        }
        return CrosswordState(clueTracker: clueTracker,
                                   initBindingsGrid: emptyBindingsGrid,
                                   initInputGrid: emptyInputGrid,
                                   initTile: initTile,
                                   initWord: initWord)
    }
    
}
