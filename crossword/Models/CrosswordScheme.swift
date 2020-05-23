//
//  CrosswordScheme.swift
//  crossword
//
//  Created by Mason Zhang on 5/4/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SwiftyJSON
//if we add other crossword formats, make a struct that takes as input a CrosswordDataJSON but conforms to CrosswordData protocol

struct Answers: Decodable {
    var across: [String]
    var down: [String]
}
struct Size: Decodable {
    var cols: Int
    var rows: Int
}
struct CrosswordDataJSON: Decodable {
    var acrossmap: String?
    var admin: String?
    var autowrap: String?
    var bbars: String?
    var circles: String?
    var code: String?
    var downmap: String?
    var hold: String?
    var id: String?
    var id2: String?
    var interpretcolors: String?
    var jnotes: String?
    var key: String?
    var mini: String?
    var notepad: String?
    var rbars: String?
    var shadecircles: String?
    var track: String?
    var type: String?
    
    var answers: Answers
    var author: String
    var clues: Answers
    var copyright: String
    var date: String
    var dow: String
    var editor: String
    var grid: [String]
    var gridnums: [Int]
    var publisher: String
    var size: Size
    var title: String
}

struct Clue {
    var clue: String
    var answer: String
    var firstTile: TileLoc
}

struct CrosswordScheme {
    
    var acrossClues: [Int: Clue]
    var downClues: [Int: Clue]
    var author: String
    var editor: String
    var publisher: String
    var copyright: String
    
    var date: String
    var dow: String
    
    var grid: [[String?]]
    var gridnums: [[Int?]]
    var numRows: Int
    var numCols: Int
    var title: String
    
    init?(jsonUrl: String) {
        guard let url = URL(string: jsonUrl) else {
            return nil
        }
        guard let json = try? Data(contentsOf: url) else {
            return nil
        }
        do {
            let a = try JSONDecoder().decode(CrosswordDataJSON.self, from: json)
        } catch {
            print(error)
        }
        guard let xword = try? JSONDecoder().decode(CrosswordDataJSON.self, from: json) else {
            return nil
        }
        
        
        self.author = xword.author
        self.editor = xword.editor
        self.publisher = xword.publisher
        self.copyright = xword.copyright
        self.date = xword.date
        self.dow = xword.dow
        self.numRows = xword.size.rows
        self.numCols = xword.size.cols
        self.title = xword.title
        
        var grid: [[String?]] = []
        var gridnums: [[Int?]] = []
        var gridnumLocs: [Int: TileLoc] = [:]
        for i in 0..<numRows {
            var gridRow: [String?] = []
            var gridnumsRow: [Int?] = []
            for j in 0..<numCols {
                let index = i * numCols + j
                let answer: String = xword.grid[index]
                if answer == "."{
                    gridRow.append(nil)
                } else {
                    gridRow.append(answer)
                }
                let number: Int = xword.gridnums[index]
                if number == 0 {
                    gridnumsRow.append(nil)
                } else {
                gridnumsRow.append(number)
                    gridnumLocs[number] = TileLoc(row: i, col: j)
                }
            }
            grid.append(gridRow)
            gridnums.append(gridnumsRow)
        }
        self.grid = grid
        self.gridnums = gridnums

        func clueNumber(of clue: String) -> Int {
            //clue format should be: [ClueNumber]. [Clue String] ex: 1. Capital of Italy
            return Int(clue.components(separatedBy: " ").first!.replacingOccurrences(of: ".", with: ""))!
        }
        var acrossClues: [Int: Clue] = [:]
        var downClues: [Int: Clue] = [:]
        for i in 0..<xword.clues.across.count {
            let clueNum: Int = clueNumber(of: xword.clues.across[i])
            let clue: Clue = Clue(clue: xword.clues.across[i], answer: xword.answers.across[i], firstTile: gridnumLocs[clueNum]!)
            acrossClues[clueNum] = clue
        }
        for i in 0..<xword.clues.down.count {
            let clueNum: Int = clueNumber(of: xword.clues.down[i])
            let clue: Clue = Clue(clue: xword.clues.down[i], answer: xword.answers.down[i], firstTile: gridnumLocs[clueNum]!)
            downClues[clueNum] = clue
        }
        self.acrossClues = acrossClues
        self.downClues = downClues
    }
}
