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

struct CrosswordView_Previews: PreviewProvider {
    
    static func parse() {
        let urlString = "https://github.com/doshea/nyt_crosswords/blob/master/1976/03/03.json"
        guard let url = URL(string: urlString) else {
            return
        }
        guard let json = try? Data(contentsOf: url) else {
            return
        }
        if let xword = try? JSONDecoder().decode(CrosswordDataJSON.self, from: json) {
            DispatchQueue.main.async {
                return xword
            }
        }
        
        
        
        
    }
    static var previews: some View {
        CrosswordView(crosswordData: parse() as! CrosswordData)
        
        
    }
}
