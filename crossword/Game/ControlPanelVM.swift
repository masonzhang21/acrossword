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
    @Binding var clueMode: Bool
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
    //syncs with the pencilMode in state.
    @Published var pencilMode: Bool = false {
        didSet {
            core.state.pencilMode = pencilMode
        }
    }
    
    init(core: CrosswordCore, clueMode: Binding<Bool>, navbarHidden: Binding<Bool>) {
        self.core = core
        self._clueMode = clueMode
        self._navbarHidden = navbarHidden
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
            core.state.input[curTile.row][curTile.col]!.color = .correct
        } else {
            core.state.input[curTile.row][curTile.col]!.color = .incorrect
        }
    }
    
    func checkWord() {
        let curWord = core.state.currentWord
        for tile in curWord {
            let guess = core.state.input[tile.row][tile.col]!.text
            let solution = core.scheme.grid[tile.row][tile.col]
            if guess == solution {
                core.state.input[tile.row][tile.col]!.color = .correct
            } else {
                core.state.input[tile.row][tile.col]!.color = .incorrect
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
                if guess == solution {
                    core.state.input[row][col]!.color = .correct
                } else {
                    core.state.input[row][col]!.color = .incorrect
                }
            }
        }
    }
    
    func revealTile() {
        let curTile = core.state.currentTile
        let solution = core.scheme.grid[curTile.row][curTile.col]!
        core.state.input[curTile.row][curTile.col] = Guess(text: solution, color: .correct)
    }
    
    func revealWord() {
        let curWord = core.state.currentWord
        for tile in curWord {
            let solution = core.scheme.grid[tile.row][tile.col]!
            core.state.input[tile.row][tile.col] = Guess(text: solution, color: .correct)
        }
    }
    
    func revealAll() {
        for row in 0..<core.scheme.numRows {
            for col in 0..<core.scheme.numCols {
                guard let solution = core.scheme.grid[row][col] else {
                    continue
                }
                core.state.input[row][col] = Guess(text: solution, color: .correct)
            }
        }
    }
    
}
