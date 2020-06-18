//
//  BoardView.swift
//  crossword
//
//  Created by Mason Zhang on 6/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

struct BoardView: View {
    
    var core: CrosswordCore
    var actions: BoardActions
    var size: CGFloat
    init(core: CrosswordCore, size: CGFloat) {
        self.core = core
        self.size = size
        actions = BoardActions(core: core)
        
    }
    
    func makeTile(at loc: TileLoc) -> some View {
        Group {
            if core.scheme.grid[loc.row][loc.col] == nil {
                Rectangle().fill(Color.black).onTapGesture {
                    self.core.toggleBoard()
                }
            } else {
                CrosswordTile(core: self.core, actions: self.actions, tile: self.core.state.tileBindings[loc.row][loc.col]!, loc: loc)
            }
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<self.core.scheme.numRows) {i in
                HStack(spacing: 0) {
                    ForEach(0..<self.core.scheme.numCols) {j in
                        self.makeTile(at: TileLoc(row: i, col: j)).border(Color.gray, width: 0.5)
                    }
                }
            }
        }.border(Color.black, width: 1).frame(maxWidth: size, maxHeight: size) //might not work for nonsquare puzzles?
    }
}

