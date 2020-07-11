//
//  TileLoc.swift
//  crossword
//
//  Created by Mason Zhang on 5/16/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation

/**
 Simple struct for representing the location of a Tile. Zero-indexed, starting from row 0 and col 0.
 */
struct TileLoc: Equatable {
    var row: Int
    var col: Int
}
