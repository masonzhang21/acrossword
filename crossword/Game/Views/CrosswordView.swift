//
//  CrosswordView.swift
//  crossword
//
//  Created by Mason Zhang on 5/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

struct GameView: View {
    
    var core: CrosswordCore
    
    init(scheme: CrosswordScheme) {
        core = CrosswordCore(scheme: scheme)
    }
    //everyone needs to share a state so
    var body: some View {
        NavigationView{
            VStack {
                //ControlPanelView(vm: ControlPanelVM(state: $vm.state))
                BoardView(core: core)
            }.padding()
        }
    }
    
}


struct CrosswordView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(scheme: CrosswordScheme(id: "")!)
    }
}

//CrosswordView needs to own scheme/state
