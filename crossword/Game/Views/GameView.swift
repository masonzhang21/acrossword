//
//  GameView.swift
//  crossword
//
//  Created by Mason Zhang on 5/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

struct GameView: View {
    
    var core: CrosswordCore!
    @State var loadingMode: Bool = false
    @State var clueMode: Bool = false {
        didSet {
            clueMode ? core.deactivateBoard() : core.activateBoard()
        }
    }
    @State var navbarHidden = true
    @EnvironmentObject var appData: AppData
    init(id: CrosswordID, user: User) {
        core = CrosswordCore(id: id, user: user, loadingFlag: $loadingMode)
    }
    
    func saveState() {
        CrosswordIO.storeCrosswordState(user: appData.user!, state: core.state, id: core.id)
        //state/id -> StoredCrossword, call Firestore store in CrosswordIO
    }
    
    var body: some View {
        NavigationView {
            GeometryReader {geometry in
                VStack(alignment: .leading) {
                    ControlPanelView(vm: ControlPanelVM(core: self.core, clueMode: self.$clueMode, navbarHidden: self.$navbarHidden)).padding([.top, .bottom])
                    if self.core.state.isMultiplayer {
                        
                    }
                    if !self.loadingMode {
                    BoardView(core: self.core, size: geometry.size.width).onTapGesture {
                        self.clueMode = false
                    }
                    }
                    if self.clueMode {
                        ClueView(core: self.core)
                    }
                }
                Spacer()
                }.padding().navigationBarTitle("").navigationBarHidden(navbarHidden)
        }.onDisappear(perform: self.saveState)
    }
}

/*
struct CrosswordView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(scheme: CrosswordScheme(id: "")!)
    }
}
*/
//CrosswordView needs to own scheme/state

