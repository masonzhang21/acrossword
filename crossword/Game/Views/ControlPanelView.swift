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
    case friends
    case info
    case settings
}

struct ControlButton: ViewModifier {
    var border: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.purple, lineWidth: 2)
    }
    
    func body(content: Content) -> some View {
        content.foregroundColor(Color.purple).padding(8).overlay(border)
    }
}

struct ControlPanelView: View {
    @ObservedObject var vm: ControlPanelVM
    @EnvironmentObject var appData: AppData
    @State var page: NavSelection?
    
    var body: some View {
        HStack {
            HStack {
                Button(action: {self.appData.currentView = ViewSelector.getView(.home)}) {
                    Image(systemName: "house").modifier(ControlButton())
                }
            }
            Spacer()
            HStack {
                Button(action: {self.vm.clueMode.toggle()}) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundColor(self.vm.clueMode ? Color.white : Color.purple)
                        .modifier(ControlButton())
                        .background(self.vm.clueMode ? Color.purple.cornerRadius(10) : Color.white.cornerRadius(10))
                }
                Button(action: {self.vm.pencilMode.toggle()}) {
                    Image(systemName: "pencil")
                        .foregroundColor(self.vm.pencilMode ? Color.white : Color.purple)
                        .modifier(ControlButton())
                        .background(self.vm.pencilMode ? Color.purple.cornerRadius(10) : Color.white.cornerRadius(10))
                    
                }
                Button(action: {self.vm.displayCheckDropdown.toggle()}) {
                    Image(systemName: "checkmark").modifier(ControlButton())
                }.actionSheet(isPresented: $vm.displayCheckDropdown) {
                    ActionSheet(title: Text("What do you want to check?"), buttons: [
                        .default(Text("Check Tile"), action: {self.vm.checkTile()}),
                        .default(Text("Check Word"), action: {self.vm.checkWord()}),
                        .default(Text("Check All"), action: {self.vm.checkAll()}),
                        .cancel()])
                }
                Button(action: {self.vm.displayRevealDropdown.toggle()}) {
                    Image(systemName: "eye").modifier(ControlButton())
                }.actionSheet(isPresented: $vm.displayRevealDropdown) {
                    ActionSheet(title: Text("What do you want to reveal?"), buttons: [
                        .default(Text("Reveal Tile"), action: {self.vm.revealTile()}),
                        .default(Text("Reveal Word"), action: {self.vm.revealWord()}),
                        .default(Text("Reveal All"), action: {self.vm.revealAll()}),
                        .cancel()])
                }
            }
            Spacer()
            HStack {
                NavigationLink(destination: AddFriendView(), tag: NavSelection.friends, selection: $page) {
                    Button(action: {
                        self.vm.prepareForNavigation()
                        self.page = .friends
                    }) {
                        Image(systemName: "person.badge.plus").modifier(ControlButton())
                    }
                }
                NavigationLink(destination: InfoView(), tag: NavSelection.info, selection: $page) {
                    Button(action: {
                        self.vm.prepareForNavigation()
                        self.page = .info
                    }) {
                        Image(systemName: "info").modifier(ControlButton())
                    }
                }
                NavigationLink(destination: SettingsView(), tag: NavSelection.settings, selection: $page) {
                    Button(action: {
                        self.vm.prepareForNavigation()
                        self.page = .settings
                    }) {
                        Image(systemName: "gear").modifier(ControlButton())
                    }
                }
            }
        }.onAppear(perform: self.vm.prepareForReturn)
    }
}

