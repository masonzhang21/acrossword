//
//  TileState.swift
//  crossword
//
//  Created by Mason Zhang on 6/2/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import Combine

class TileState: ObservableObject {
    @Published var isFocused: Bool = false
    @Published var isCurrentTile: Bool = false
    @Published var isCurrentWord: Bool = false
    @Published var text: String = ""
}
