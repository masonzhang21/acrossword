//
//  CrosswordView.swift
//  crossword
//
//  Created by Mason Zhang on 5/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

struct CrosswordView: View {
    
    @ObservedObject var vm: CrosswordVM
    
    init(scheme: CrosswordScheme) {
        vm = CrosswordVM(scheme: scheme)
    }
    
    var body: some View {
        NavigationView{
            VStack {
            ControlPanelView(vm: ControlPanelVM(state: $vm.state))
            GeometryReader{geometry in
                self.buildGrid(geometry)
            }
                
            }.padding()
        }
    }
    
    func buildGrid(_ geometry: GeometryProxy) -> some View{
        func makeTile(at loc: TileLoc) -> some View {
            Group {
            if vm.scheme.grid[loc.row][loc.col] == nil {
                Rectangle().fill(Color.black).onTapGesture {
                    self.vm.state.focusedTile = nil
                    self.vm.state.currentWord = nil
                }
            } else {
                CrosswordTile(vm: self.vm, loc: loc)
                }
            }
        }
        
        return VStack(spacing: 0) {
            ForEach(0..<self.vm.scheme.numRows) {i in
                HStack(spacing: 0) {
                    ForEach(0..<self.vm.scheme.numCols) {j in
                        makeTile(at: TileLoc(row: i, col: j)).border(Color.gray, width: 0.5)
                    }
                }
            }
            }.border(Color.black, width: 1).frame(width: geometry.size.width, height: geometry.size.width)
    }
}


struct CrosswordView_Previews: PreviewProvider {
    static var previews: some View {
        CrosswordView(scheme: CrosswordScheme(id: "")!)
    }
}
