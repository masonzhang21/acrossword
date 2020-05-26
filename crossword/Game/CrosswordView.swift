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
        GeometryReader{geometry in
            self.buildGrid(geometry)
        }
    }
    
    func buildGrid(_ geometry: GeometryProxy) -> some View{
        let tileLen: CGFloat = geometry.size.width / CGFloat(max(vm.scheme.numRows, vm.scheme.numCols))
        
        return VStack(spacing: 0) {
            ForEach(0..<self.vm.scheme.numRows) {i in
                HStack(spacing: 0) {
                    ForEach(0..<self.vm.scheme.numCols) {j in
                        CrosswordTile(vm: self.vm, loc: TileLoc(row: i, col: j)).frame(width: tileLen, height: tileLen).border(Color.gray, width: 0.5)
                    }
                }
            }
        }.border(Color.black)
    }
}


struct CrosswordView_Previews: PreviewProvider {
static var previews: some View {
    CrosswordView(scheme: CrosswordScheme(id: "")!)
}
}
