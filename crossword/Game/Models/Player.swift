//
//  Player.swift
//  crossword
//
//  Created by Mason Zhang on 9/15/20.
//  Copyright © 2020 mason. All rights reserved.
//
import Foundation
import UIKit
//for multiplayer mode

struct Player: Equatable {
    let username: String
    let color: UIColor
    var currentTile: TileLoc
    var currentWord: [TileLoc]
    
}
