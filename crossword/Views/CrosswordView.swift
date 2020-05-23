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
        ForEach(0..<self.vm.scheme.numRows) {i in
            HStack {
                ForEach(0..<self.vm.scheme.numCols) {j in
                    CrosswordTile(vm: self.vm, loc: TileLoc(row: i, col: j))
                }
            }
        }
    }
}
