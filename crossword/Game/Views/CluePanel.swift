//
//  CluePanel.swift
//  crossword
//
//  Created by Mason Zhang on 6/12/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

struct CluePanel: View {
    var actions: BoardActions
    var core: CrosswordCore
    @ObservedObject var clueTracker: ClueTracker
    
    var body: some View {
        HStack {
            Button(action: {self.actions.prevWord()}) {
                Image(systemName: "arrowtriangle.left").foregroundColor(Color.white).frame(maxHeight: .infinity)
            }.padding().background(Constants.Colors.cluePanelArrows)
            Spacer()
            Button(action: self.core.flipDirection) {
                Text(clueTracker.clue.clue).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading).foregroundColor(.black)
            }
            Spacer()
            Button(action: {self.actions.nextWord()}) {
                Image(systemName: "arrowtriangle.right").foregroundColor(Color.white).frame(maxHeight: .infinity)
            }.padding().background(Constants.Colors.cluePanelArrows)
        }.frame(width: UIScreen.main.bounds.size.width, height: 60, alignment: .leading).background(Constants.Colors.cluePanel)
    }
}

/*
struct CluePanel_Previews: PreviewProvider {
    static var previews: some View {
        CluePanel(actions: BoardActions(core: CrosswordCore(scheme: CrosswordScheme(id: "")!)), core: CrosswordCore(scheme: CrosswordScheme(id: "")!), clueTracker: ClueTracker(scheme: CrosswordScheme(id: "")!))
    }
}
*/
