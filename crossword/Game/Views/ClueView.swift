//
//  ClueView.swift
//  crossword
//
//  Created by Mason Zhang on 5/27/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI
import Foundation
struct ClueView: View {
    var core: CrosswordCore
    @State var selectedClue: Clue {
        didSet {
            if selectedClue == oldValue {
                core.toggleClueMode()
                return
            }
            self.core.state.direction = selectedClue.dir
            let newWord = self.core.tilesInSameWord(as: selectedClue.firstTile, dir: selectedClue.dir)
            self.core.updateCurrentWord(to: newWord)
            let firstEmptyTileInClue = self.core.firstEmptyTile(in: newWord)
            self.core.updateCurrentTile(to: firstEmptyTileInClue)
            
        }
    }
    var acrossClues: [(Int, String, Clue)]
    var downClues: [(Int, String, Clue)]
    
    init(core: CrosswordCore) {
        self.core = core
        let currentClue: Clue = core.state.clueTracker.clue
        _selectedClue = State(initialValue: currentClue)
        
        let regex = try? NSRegularExpression(
            pattern: "^[\\d][\\d]?\\.?\\s?(.*)$",
            options: .caseInsensitive
        )
        acrossClues = core.scheme.acrossClues.map{($0, $1)}.sorted(by: {$0.0 < $1.0}).map {clueNum, clue -> (Int, String, Clue) in
            guard let match = regex?.firstMatch(in: clue.clue, range: NSRange(location: 0, length: clue.clue.count)), let clueRange = Range(match.range(at: 1), in: clue.clue) else {
                return (clueNum, clue.clue, clue)
                
            }
            //1. Talks on and on --> Talks on and on
            let extractedClue = clue.clue[clueRange]
            return (clueNum, String(extractedClue), clue)
        }
        downClues = core.scheme.downClues.map{($0, $1)}.sorted(by: {$0.0 < $1.0}).map {clueNum, clue -> (Int, String, Clue) in
            guard let match = regex?.firstMatch(in: clue.clue, range: NSRange(location: 0, length: clue.clue.count)), let clueRange = Range(match.range(at: 1), in: clue.clue) else {
                return (clueNum, clue.clue, clue)
            }
            //1. Talks on and on --> Talks on and on
            let extractedClue = clue.clue[clueRange]
            return (clueNum, String(extractedClue), clue)
        }
    }
    //we're using a clue's TileLoc as its UUID
    var body: some View {
        return HStack(spacing: 0){
            VStack(alignment: .leading, spacing: 0) {
                Text("Across").frame(maxWidth: .infinity).padding(.vertical, 7).background(Color(red: 198/255, green: 122/255, blue: 255))
                ScrollView {
                    VStack(alignment: .leading, spacing: 0){
                        ForEach(acrossClues, id: \.0) { (clueNum, clueText, clue) in
                            Button(action: {self.selectedClue = clue}) {
                                HStack(alignment: .top){
                                    Text(String(clueNum)).fontWeight(.bold).frame(minWidth: 25, alignment: .leading)
                                    Text(clueText).frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }.padding(3).background(clue == self.selectedClue ? Constants.Colors.selectedClue : Color.white).foregroundColor(.black).font(.footnote).border(Constants.Colors.lightGrey, width: 0.5)
                        }
                    }
                }
                
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).border(Color.black, width: 2).cornerRadius(5).padding(.trailing, 3)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Down").frame(maxWidth: .infinity).padding(.vertical, 7).background(Color(red: 198/255, green: 122/255, blue: 255))
                ScrollView {
                    VStack(alignment: .leading, spacing: 0){
                        ForEach(downClues, id: \.0) { (clueNum, clueText, clue) in
                            Button(action: {self.selectedClue = clue}) {
                                HStack(alignment: .top){
                                    Text(String(clueNum)).fontWeight(.bold).frame(minWidth: 25, alignment: .leading)
                                    Text(clueText).frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }.padding(3).background(clue == self.selectedClue ? Constants.Colors.selectedClue : Color.white).foregroundColor(.black).font(.footnote).border(Constants.Colors.lightGrey, width: 0.5)
                        }
                    }
                }
                
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).border(Color.black, width: 2).cornerRadius(5).padding(.leading, 3)
        }
    }
}

