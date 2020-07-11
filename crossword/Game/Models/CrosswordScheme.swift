//
//  CrosswordScheme.swift
//  crossword
//
//  Created by Mason Zhang on 5/4/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Answers: Decodable {
    var across: [String]
    var down: [String]
}
struct Size: Decodable {
    var cols: Int
    var rows: Int
}

struct Clue: Equatable {
    let clue: String
    let answer: String
    let firstTile: TileLoc
    let num: Int
    let dir: Direction
}

struct CrosswordScheme {
    let acrossClues: [Int: Clue]
    let downClues: [Int: Clue]
    let acrossClueNums: [Int]
    let downClueNums: [Int]
    let author: String
    let editor: String
    let publisher: String
    let copyright: String
    
    let date: String
    let dow: String
    
    let grid: [[String?]]
    let gridnums: [[Int?]]
    let numRows: Int
    let numCols: Int
    let title: String
    
    init(json: JSON) {

            /*
            acrossClues = [:]; downClues = [:]
            acrossClueNums = []; downClueNums = []
            author = ""; editor = ""; publisher = ""; copyright = ""; date = ""; dow = ""
            grid = []; gridnums = []
            numRows = 0; numCols = 0;
            title = ""
            return
 */
        
        
        self.author = json["author"].stringValue
        self.editor = json["editor"].stringValue
        self.publisher = json["publisher"].stringValue
        self.copyright = json["copyright"].stringValue
        self.date = json["date"].stringValue
        self.dow = json["dow"].stringValue
        self.numRows = json["size"]["rows"].intValue
        self.numCols = json["size"]["cols"].intValue
        self.title = json["title"].stringValue
        
        let answers: [String] = json["grid"].arrayObject as! [String]
        let gnums: [Int] = json["gridnums"].arrayObject as! [Int]
        var grid: [[String?]] = []
        var gridnums: [[Int?]] = []
        var gridnumLocs: [Int: TileLoc] = [:]
        for i in 0..<numRows {
            var gridRow: [String?] = []
            var gridnumsRow: [Int?] = []
            for j in 0..<numCols {
                let index = i * numCols + j
                let answer: String = answers[index]
                if answer == "."{
                    gridRow.append(nil)
                } else {
                    gridRow.append(answer)
                }
                let number: Int = gnums[index]
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
        let aClues: [String] = json["clues"]["across"].arrayObject as! [String]
        let dClues: [String] = json["clues"]["down"].arrayObject as! [String]
        let aAnswers: [String] = json["answers"]["across"].arrayObject as! [String]
        let dAnswers: [String] = json["answers"]["down"].arrayObject as! [String]
        var acrossClues: [Int: Clue] = [:]
        var downClues: [Int: Clue] = [:]
        var acrossClueNums: [Int] = []
        var downClueNums: [Int] = []
        for i in 0..<aClues.count {
            let clueNum: Int = clueNumber(of: aClues[i])
            let clue: Clue = Clue(clue: aClues[i], answer: aAnswers[i], firstTile: gridnumLocs[clueNum]!, num: clueNum, dir: .across)
            acrossClueNums.append(clueNum)
            acrossClues[clueNum] = clue
        }
        for i in 0..<dClues.count {
            let clueNum: Int = clueNumber(of: dClues[i])
            let clue: Clue = Clue(clue: dClues[i], answer: dAnswers[i], firstTile: gridnumLocs[clueNum]!, num: clueNum, dir: .down)
            downClueNums.append(clueNum)
            downClues[clueNum] = clue
        }
        self.acrossClues = acrossClues
        self.downClues = downClues
        self.acrossClueNums = acrossClueNums
        self.downClueNums = downClueNums
    }
}
