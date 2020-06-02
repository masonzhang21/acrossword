//
//  ControlPanelView.swift
//  crossword
//
//  Created by Mason Zhang on 5/26/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

enum NavSelection {
    case clues
}
struct ControlPanelView: View {
    //[expand clues] [pencil] [check -> dropdown clue/word/puzzle] [reveal -> dropdown] [info] [settings] [refresh puzzle] <- completed OR [share]
    @ObservedObject var vm: ControlPanelVM
    @EnvironmentObject var appData: AppData
    @State var navSelection: NavSelection?
    var border: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.purple, lineWidth: 2)
    }
    var body: some View {
        HStack {
            HStack {
                Button(action: {self.appData.currentView = ViewSelector.getView(.home)}) {
                    Image(systemName: "house").foregroundColor(Color.purple).padding(8).overlay(border)
                }
            }
            Spacer()
            HStack {
                NavigationLink(destination: ClueView(), tag: NavSelection.clues, selection: $navSelection) {
                    Button(action: {
                        self.navSelection = .clues
                        
                    }) {
                        Image(systemName: "doc.text.magnifyingglass").foregroundColor(Color.purple).padding(8).overlay(border)
                    }
                }
                Button(action: {self.vm.state.pencilMode.toggle()}) {
                    Image(systemName: "pencil").foregroundColor(self.vm.state.pencilMode ? Color.white : Color.purple).padding(8).background(self.vm.state.pencilMode ? Color.purple.cornerRadius(10) : Color.white.cornerRadius(10)).overlay(border)
                }
                Button(action: {
                    self.vm.displayCheckDropdown.toggle()}) {
                        Image(systemName: "checkmark").foregroundColor(Color.purple).padding(8).overlay(border)
                }.actionSheet(isPresented: $vm.displayCheckDropdown) {
                    ActionSheet(title: Text("What do you want to check?"), buttons: [.default(Text("Check Tile"), action: {self.vm.checkTile()}), .default(Text("Check Word"), action: {self.vm.checkWord()}), .cancel()])
                }
                Button(action: {self.vm.displayRevealDropdown.toggle()}) {
                    Image(systemName: "eye").foregroundColor(Color.purple).padding(8).overlay(border)
                }.actionSheet(isPresented: $vm.displayRevealDropdown) {
                    ActionSheet(title: Text("What do you want to reveal?"), buttons: [.default(Text("Reveal Tile"), action: {self.vm.revealTile()}), .default(Text("Reveal Word"), action: {self.vm.revealWord()}), .cancel()])
                }
            }
            Spacer()
            HStack {
                NavigationLink(destination: AddFriendView()) {
                    Image(systemName: "person.badge.plus").foregroundColor(Color.purple).padding(8).overlay(border)
                }
                NavigationLink(destination: InfoView()) {
                    Image(systemName: "info").foregroundColor(Color.purple).padding(8).overlay(border)
                }
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear").foregroundColor(Color.purple).padding(8).overlay(border)
                }
            }
        }.onAppear(perform: {print("Hi")}).onTapGesture {

        }
    }
}

/*
 struct ControlPanelView_Previews: PreviewProvider {
 static var previews: some View {
 ControlPanelView()
 }
 }
 */

