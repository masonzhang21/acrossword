//
//  CrosswordId.swift
//  crossword
//
//  Created by Mason Zhang on 7/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation

enum CrosswordStatus {
    case completed
    case inProgress
    case notStarted
}

struct CrosswordID: Codable {
    let newspaper: String
    let day: String
    let month: String
    let year: String
    
    var idString: String {
        get {
            return newspaper + day + month + year
        }
    }
}
