//
//  ControlPanelVM.swift
//  crossword
//
//  Created by Mason Zhang on 5/27/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class ControlPanelVM: ObservableObject {
    var core: CrosswordCore
    @ObservedObject var modes: ModesTracker
    @Binding var secondsElapsed: Int
    @Binding var navbarHidden: Bool
    @Published var displayCheckDropdown: Bool = false {
        didSet {
            if displayCheckDropdown {
                core.state.active = false
            } else {
                core.state.active = true
            }
        }
    }
    @Published var displayRevealDropdown: Bool = false {
        didSet {
            if displayRevealDropdown {
                core.state.active = false
            } else {
                core.state.active = true
            }
        }
    }
    
    
    init(core: CrosswordCore, secondsElapsed: Binding<Int>, navbarHidden: Binding<Bool>) {
        self.core = core
        self.modes = core.state.modes
        self._navbarHidden = navbarHidden
        self._secondsElapsed = secondsElapsed
    }
    
    func prepareForNavigation() {
        navbarHidden = false
        core.state.active = false
    }
    func prepareForReturn() {
        navbarHidden = true
        core.state.active = true
    }
    
    func checkTile() {
        let curTile = core.state.currentTile
        let guess = core.state.input[curTile.row][curTile.col]!.text
        let solution = core.scheme.grid[curTile.row][curTile.col]
        if guess == solution {
            core.updateInputConfidence(at: curTile, to: .correct)
        } else {
            core.updateInputConfidence(at: curTile, to: .incorrect)
        }
    }
    
    func checkWord() {
        let curWord = core.state.currentWord
        for tile in curWord {
            let guess = core.state.input[tile.row][tile.col]!.text
            let solution = core.scheme.grid[tile.row][tile.col]
            if guess == solution {
                core.updateInputConfidence(at: tile, to: .correct)
            } else {
                core.updateInputConfidence(at: tile, to: .incorrect)
            }
        }
    }
    
    func checkAll() {
        for row in 0..<core.scheme.numRows {
            for col in 0..<core.scheme.numCols {
                guard let input = core.state.input[row][col] else {
                    continue
                }
                let guess = input.text
                let solution = core.scheme.grid[row][col]
                let loc = TileLoc(row: row, col: col)
                if guess == solution {
                    core.updateInputConfidence(at: loc, to: .correct)
                } else {
                    core.updateInputConfidence(at: loc, to: .incorrect)
                }
            }
        }
    }
    
    func revealTile() {
        let curTile = core.state.currentTile
        let solution = core.scheme.grid[curTile.row][curTile.col]!
        core.updateInput(at: curTile, to: TileInput(text: solution, font: .correct))
    }
    
    func revealWord() {
        let curWord = core.state.currentWord
        for tile in curWord {
            let solution = core.scheme.grid[tile.row][tile.col]!
            core.updateInput(at: tile, to: TileInput(text: solution, font: .correct))
        }
    }
    
    func revealAll() {
        for row in 0..<core.scheme.numRows {
            for col in 0..<core.scheme.numCols {
                guard let solution = core.scheme.grid[row][col] else {
                    continue
                }
                let loc = TileLoc(row: row, col: col)
                core.updateInput(at: loc, to: TileInput(text: solution, font: .correct))
            }
        }
    }
    
}
