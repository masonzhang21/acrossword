//
//  StoredCrossword.swift
//  crossword
//
//  Created by Mason Zhang on 7/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation

struct StoredCrossword: Codable {
    var input: [Int: [TileInput?]]
    var id: CrosswordID
    var timeSinceLastChange: Int
    var multiplayerID: String?
    
}
