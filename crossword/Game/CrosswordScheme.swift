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
    var acrossClueNums: [Int]
    var downClueNums: [Int]
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
    
    init?(id: String) {
        let json: JSON
        let group = DispatchGroup()
        group.enter()
        
        guard let path = Bundle.main.path(forResource: "20", ofType: "json", inDirectory: "1976/01") else {
            return nil
        }
        guard let data = NSData(contentsOfFile: path) else {
            return nil
        }
        do {
            json = try JSON(data: data as Data)
            group.leave()
        } catch {
            return nil
        }
        group.wait()
        
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
            let clue: Clue = Clue(clue: aClues[i], answer: aAnswers[i], firstTile: gridnumLocs[clueNum]!)
            acrossClueNums.append(clueNum)
            acrossClues[clueNum] = clue
        }
        for i in 0..<dClues.count {
            let clueNum: Int = clueNumber(of: dClues[i])
            let clue: Clue = Clue(clue: dClues[i], answer: dAnswers[i], firstTile: gridnumLocs[clueNum]!)
            downClueNums.append(clueNum)
            downClues[clueNum] = clue
        }
        self.acrossClues = acrossClues
        self.downClues = downClues
        self.acrossClueNums = acrossClueNums
        self.downClueNums = downClueNums
    }
}
