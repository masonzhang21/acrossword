//
//  TileLoc.swift
//  crossword
//
//  Created by Mason Zhang on 5/16/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SocketIO
/**
 Simple struct for representing the location of a Tile. Zero-indexed, starting from row 0 and col 0.
 */
struct TileLoc: SocketData, Equatable, Codable {
    var row: Int
    var col: Int
    
    init(location: [String: Int]) {
        row = location["row"]!
        col = location["col"]!
    }
    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
    func socketRepresentation() -> SocketData {
        return ["row": row, "col": col]
    }
}
