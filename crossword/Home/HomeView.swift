//
//  HomeView.swift
//  crossword
//
//  Created by Mason Zhang on 4/20/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var vm: HomeVM
    @EnvironmentObject var appData: AppData
    var id1: CrosswordID = CrosswordID(newspaper: "nyt", day: "10", month: "01", year: "1976")
    var id2: CrosswordID = CrosswordID(newspaper: "nyt", day: "11", month: "02", year: "1976")

    var body: some View {
        VStack{
            Button(action: {self.vm.signOut()})
            {
                Text("Sign Out")
            }.padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .foregroundColor(Color(UIColor.black))
                .cornerRadius(10)
            if (appData.user != nil) {
            Text(appData.user!.uid)
            }
            Button(action: {self.appData.changeView(view: GameView(id: self.id1, user: self.appData.user!))}) {
                Text("Crossword 1!").padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .foregroundColor(Color(UIColor.black))
                .cornerRadius(10)
            }
            Button(action: {self.appData.changeView(view: GameView(id: self.id2, user: self.appData.user!))}) {
                Text("Crossword 2!").padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .foregroundColor(Color(UIColor.black))
                .cornerRadius(10)
            }

        }//.onAppear(perform: {self.appData.changeView(view: GameView(id: self.id))})
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(vm: HomeVM())
    }
}
