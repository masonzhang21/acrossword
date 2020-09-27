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
    let color: Color
    
    init() {
        self.color = Constants.Colors.controlButtonPrimary
    }
    init(color: Color) {
        self.color = color
    }
    var border: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.purple, lineWidth: 2)
    }
    
    func body(content: Content) -> some View {
        content.foregroundColor(self.color).padding([.leading, .trailing], 1).frame(width: 30, height: 30)//.overlay(border)
    }
}

struct ControlPanelView: View {
    @ObservedObject var vm: ControlPanelVM
    @EnvironmentObject var appData: AppData
    @State var page: NavSelection?
    
    var body: some View {
        VStack{
            HStack {
                Group {
                    Button(action: {self.appData.currentView = ViewSelector.getView(.home)}) {
                        Image(systemName: "house").modifier(ControlButton())
                    }
                    Text("50:30").padding(.leading, 5)
                }

                Spacer()
                Group {
                    Button(action: {self.vm.core.toggleClueMode()}) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .modifier(ControlButton(color: self.vm.modes.clueMode ? Color.white : Constants.Colors.controlButtonPrimary))
                            .background(self.vm.modes.clueMode ? Constants.Colors.controlButtonActive.cornerRadius(10) : Color.white.cornerRadius(10))
                    }
                    Button(action: {self.vm.modes.pencilMode.toggle()}) {
                        Image(systemName: "pencil")
                            .modifier(ControlButton(color: self.vm.modes.pencilMode ? Color.white : Color.purple))
                            .background(self.vm.modes.pencilMode ? Constants.Colors.controlButtonActive.cornerRadius(10) : Color.white.cornerRadius(10))
                        
                    }
                    Button(action: {


                    }) {
                        Image(systemName: "checkmark").modifier(ControlButton()).onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            self.vm.core.deactivateBoard()

                            self.vm.displayCheckDropdown.toggle()

                        })
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
                Group {
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
            }.padding(.bottom, 5)
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    Circle().fill(Color.blue)
                        .frame(width: 20, height: 20)
                    Text("PlaceholdePlaceholderPlaceholderPlaceholderPlaceholderPlaceholderPlaceholderPlaceholderPlaceholderr")
                }
            }
        }.onAppear(perform: self.vm.prepareForReturn)
    }
}

