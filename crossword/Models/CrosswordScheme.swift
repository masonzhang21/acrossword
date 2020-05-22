//
//  CrosswordScheme.swift
//  crossword
//
//  Created by Mason Zhang on 5/4/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation

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

struct CrosswordScheme {
    
    var clues: [[String: String]]
    
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
        for i in 0..<numRows {
            var gridRow: [String?] = []
            var gridnumsRow: [Int?] = []
            for j in 0..<numCols {
                let index = i * numCols + j
                let answer: String = xword.grid[index]
                let number: Int = xword.gridnums[index]
                if answer == "."{
                    gridRow.append(nil)
                } else {
                    gridRow.append(answer)
                }
                if number == 0 {
                    gridnumsRow.append(nil)
                } else {
                gridnumsRow.append(number)
                }
            }
            grid.append(gridRow)
            gridnums.append(gridnumsRow)
        }
        self.grid = grid
        self.gridnums = gridnums

        
        var acrossClues: [String: String] = [:]
        var downClues: [String: String] = [:]
        for i in 0..<xword.clues.across.count {
            acrossClues[xword.clues.across[i]] = xword.answers.across[i]
        }
        for i in 0..<xword.clues.down.count {
            downClues[xword.clues.down[i]] = xword.answers.down[i]
        }
        self.clues = [acrossClues, downClues]
    }
}
