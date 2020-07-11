//
//  RootView.swift
//  crossword
//
//  Created by Mason Zhang on 4/14/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

struct RootView: View {
    
    var vm: RootVM
    @EnvironmentObject var appData: AppData
    var body: some View {
        appData.currentView.onAppear(perform: {
            self.vm.setAuthStateChangeListener(appData: self.appData)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(vm: RootVM()).environmentObject(AppData())
    }
}
