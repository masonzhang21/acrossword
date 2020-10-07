//
//  PlayersPanelView.swift
//  crossword
//
//  Created by Mason Zhang on 9/26/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

struct PlayersPanelView: View {
    @Binding var players: [String: Player]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                if self.players.values.isEmpty {
                    Text("No players connected")
                }
                ForEach (Array(self.players.values), id: \.username) { player in
                    HStack(spacing: 5) {
                    Circle().fill(Color(player.color))
                        .frame(width: 15, height: 15)
                    Text(player.username)
                    }
                }
                
            }.padding(10).font(.caption)
        }.frame(maxWidth: .infinity).background(Constants.Colors.faintGrey).cornerRadius(10)
    }
}
