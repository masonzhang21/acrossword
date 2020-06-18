//
//  GameView.swift
//  crossword
//
//  Created by Mason Zhang on 5/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

/*
 
 */
struct GameView: View {
    
    var core: CrosswordCore
    @State var clueMode: Bool = false
    @State var navbarHidden = true
    init(scheme: CrosswordScheme) {
        core = CrosswordCore(scheme: scheme)
    }
    
    var body: some View {
        NavigationView {
            GeometryReader {geometry in
                VStack(alignment: .leading) {
                    ControlPanelView(vm: ControlPanelVM(core: self.core, clueMode: self.$clueMode, navbarHidden: self.$navbarHidden)).padding([.top, .bottom])
                    if self.core.state.isMultiplayer {
                        
                    }
                    BoardView(core: self.core, size: geometry.size.width)//modifier make small if clueMode
                    if self.clueMode {
                        //make clueview visible and bigger if clueMode=true
                    }
                }
                Spacer()
                }.padding().navigationBarTitle("").navigationBarHidden(navbarHidden)
        }
    }
}


struct CrosswordView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(scheme: CrosswordScheme(id: "")!)
    }
}

//CrosswordView needs to own scheme/state

