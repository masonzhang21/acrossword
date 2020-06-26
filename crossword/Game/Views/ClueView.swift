//
//  ClueView.swift
//  crossword
//
//  Created by Mason Zhang on 5/27/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

struct ClueView: View {
    var core: CrosswordCore
    @State var selectedClue: Clue {
        didSet {
            if selectedClue == oldValue {
                //core.activateBoard()
                return
            }
            self.core.state.direction = selectedClue.dir
            self.core.state.currentWord = self.core.tilesInSameWord(as: selectedClue.firstTile, dir: selectedClue.dir)
            self.core.state.currentTile = self.core.firstEmptyTile(in: self.core.state.currentWord)
        }
    }
    
    init(core: CrosswordCore) {
        self.core = core
        let currentClue: Clue = core.state.clueTracker.clue
        _selectedClue = State(initialValue: currentClue)
    }
    //we're using a clue's TileLoc as its UUID
    var body: some View {
        let acrossClues: [Clue] = core.scheme.acrossClues.map{($0, $1)}.sorted(by: {$0.0 < $1.0}).map({$1})
        let downClues: [Clue] = core.scheme.downClues.map{($0, $1)}.sorted(by: {$0.0 < $1.0}).map({$1})
        
        return HStack(spacing: 0){
            ScrollView {
                VStack(alignment: .leading) {
                    Text("ACROSS:").frame(maxWidth: .infinity).padding(.vertical, 5).background(Color.purple).padding(.bottom, 5)
                    ForEach(acrossClues, id: \.num) { clue in
                        Button(action: {self.selectedClue = clue}) {
                            Text(clue.clue).frame(maxWidth: .infinity, alignment: .leading).padding([.horizontal, .bottom], 5).background(clue == self.selectedClue ? Constants.Colors.darkGrey : Color.white)
                        }
                    }
                }
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).border(Color.black, width: 2)
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text("DOWN:").frame(maxWidth: .infinity).padding(.vertical, 5).background(Color.purple).padding(.bottom, 5)
                    ForEach(downClues, id: \.num) { clue in
                        Button(action: {self.selectedClue = clue}) {
                            Text(clue.clue).frame(maxWidth: .infinity, alignment: .leading).padding([.horizontal, .bottom], 5).background(clue == self.selectedClue ? Constants.Colors.darkGrey : Color.white)
                        }
                    }
                }
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).border(Color.black, width: 2)
        }
    }
}

