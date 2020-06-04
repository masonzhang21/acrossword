//
//  CrosswordView.swift
//  crossword
//
//  Created by Mason Zhang on 5/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

struct CrosswordView: View {
    lazy var state: CrosswordState
    var scheme: CrosswordScheme
    
    init(scheme: CrosswordScheme) {
        vm = CrosswordVM(scheme: scheme)
    }
    //everyone needs to share a state so
    var body: some View {
        NavigationView{
            VStack {
                ControlPanelView(vm: ControlPanelVM(state: $vm.state))
            }.padding()
        }
    }
    
}


struct CrosswordView_Previews: PreviewProvider {
    static var previews: some View {
        CrosswordView(scheme: CrosswordScheme(id: "")!)
    }
}

//CrosswordView needs to own scheme/state
