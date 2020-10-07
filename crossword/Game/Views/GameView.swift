//
//  GameView.swift
//  crossword
//
//  Created by Mason Zhang on 5/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

struct GameView: View {
    
    var core: CrosswordCore
    @ObservedObject var state: CrosswordState
    @ObservedObject var modes: ModesTracker
    @State var navbarHidden = true
    @EnvironmentObject var appData: AppData
    init(id: CrosswordID, user: User) {
        core = CrosswordCore(id: id, user: user)
        state = core.state
        modes = core.state.modes
    }
    
    func saveState() {
        //if core.multiplayerID == nil {
        CrosswordIO.storeCrosswordState(user: appData.user!, state: core.state, id: core.id)
        //}
    }
    
    var body: some View {
        NavigationView {
            GeometryReader {geometry in
                VStack(alignment: .leading) {
                    ControlPanelView(vm: ControlPanelVM(core: self.core, secondsElapsed: self.$state.secondsElapsed, navbarHidden: self.$navbarHidden))
                    if self.modes.multiplayerMode {
                        PlayersPanelView(players: self.$state.players)
                    }
                    if self.modes.readyMode {
                        BoardView(core: self.core, size: geometry.size.width)
                    } else {
                        if #available(iOS 14.0, *) {
                            ProgressView()     .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.controlButtonPrimary))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .scaleEffect(4, anchor: .center)
                                .foregroundColor(.black)
                                .font(.caption)
                        } else {
                            Text("Loading...")

                        }
                    }
                    if self.modes.clueMode {
                        ClueView(core: self.core)
                    }
                }
                Spacer()
                }.padding().navigationBarTitle("").navigationBarHidden(navbarHidden)
        }.onDisappear(perform: self.saveState)
    }
}


struct CrosswordView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(id: CrosswordID(newspaper: "nyt", day: "10", month: "01", year: "1976"), user: User(uid: "whatever", email: "whaterver1@gmail.com"))
    }
}


