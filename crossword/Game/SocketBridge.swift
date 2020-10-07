//
//  MultiplayerBridge.swift
//  crossword
//
//  Created by Mason Zhang on 7/17/20.
//  Copyright © 2020 mason. All rights reserved.
//

/*
 1) check for percentCompleted = 100 on load
 2) update timer
 */
import Foundation
import SocketIO
import SwiftyJSON
class SocketBridge {
    
    var manager : SocketManager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
    var socket: SocketIOClient!
    var multiplayerID: String
    var state: CrosswordState
    init(username: String, multiplayerID: String, state: CrosswordState) {
        self.multiplayerID = multiplayerID
        self.state = state
        socket = manager.defaultSocket
        addHandlers(username: username, multiplayerID: multiplayerID)
        socket.connect()
        
    }
    
    func serialize1DArray(arr: [SocketData])  -> [SocketData]{
        return arr.map { (ele: SocketData) in try! ele.socketRepresentation() }
    }
    func serialize2DArray(arr: [[SocketData?]]) -> [[SocketData?]] {
        return arr.map { (row: [SocketData?]) in
            row.map {(ele: SocketData?) in
                if let ele = ele {
                    return try! ele.socketRepresentation()
                } else {
                    return nil
                }
            }
        }
    }
    
    func addHandlers(username: String, multiplayerID: String) {
        socket.on(clientEvent: .connect) {[weak self] _, _ in
            let initializeInformation: [String: SocketData] = ["playerID": username, "gameID": multiplayerID, "curTile": self!.state.currentTile.socketRepresentation(),
                                                               "curWord": self!.serialize1DArray(arr: self!.state.currentWord), "curInput": self!.serialize2DArray(arr: self!.state.input), "secondsElapsed": self!.state.secondsElapsed ]
            self!.socket.emit("join", initializeInformation)
        }
        
        socket.on("ready") {[weak self] data, ack in
            let game = data[0] as! [String: Any]
            //initialize local input to synced multiplayer input
            let rawInput = game["input"] as! [[[String: Any]?]]
            let initialInput = rawInput.map { row in
                row.map {  ele -> TileInput? in
                    ele == nil ? nil : TileInput(serializedTileInput: ele!)
                }
            }
            self!.state.input = initialInput
            self!.state.secondsElapsed = game["secondsElapsed"] as! Int
            //set up player objects for other players in the game
            let players = game["connectedPlayers"] as! [String: [String: Any]]
            for (playerID, player) in players {
                if username == playerID {
                    continue
                }
                self!.state.addPlayer(playerInfo: player)
            }
            self!.state.modes.syncMode = game["syncMode"] as! Bool
            self!.state.modes.readyMode = true
            self!.state.modes.multiplayerMode = true
        }
        
        socket.on("onInputS2C") {[weak self] data, ack in
            let loc = TileLoc(location: data[0] as! [String: Int])
            let tileInput: TileInput =  TileInput(serializedTileInput: data[1] as! [String: Any])
            self!.state.input[loc.row][loc.col] = tileInput
        }
        
        socket.on("focusedChangeS2C") {[weak self] data, ack in
            let newTile: TileLoc = TileLoc(location: data[0] as! [String: Int])
            self!.state.focusedTile = newTile
        }
        socket.on("tileChangeS2C") {[weak self] data, ack in
            let playerID: String = data[0] as! String
            let newTile: TileLoc = TileLoc(location: data[1] as! [String: Int])
            let selfInitiated: Bool = playerID == username
            switch (selfInitiated, self!.state.modes.syncMode) {
            case (_, true):
                //update focusedTile and everyone else's currentTile (sync)
                self!.state.focusedTile = newTile
                for (id, _) in self!.state.players {
                    self!.state.setActive(tile: newTile, for: id)
                }
            case (true, false):
                //update focusedTile (self-initiated)
                self!.state.focusedTile = newTile
            case (false, false):
                //update the origin player's tile
                self!.state.setActive(tile: newTile, for: playerID)
            }
        }
        socket.on("wordChangeS2C") {[weak self] data, ack in
            let playerID: String = data[0] as! String
            let locs = data[1] as! [[String: Int]]
            let newWord: [TileLoc] = locs.map {loc -> TileLoc in TileLoc(location: loc)}
            let selfInitiated: Bool = playerID == username
            switch (selfInitiated, self!.state.modes.syncMode) {
            case (_, true):
                //update own word and everyone's word
                self!.state.currentWord = newWord
                for (id, _) in self!.state.players {
                    self!.state.setActive(word: newWord, for: id)
                }
            case (true, false):
                //update own word (self-initiated)
                self!.state.currentWord = newWord
            case (false, false):
                //update the origin player's word
                self!.state.setActive(word: newWord, for: playerID)
            }
        }
        socket.on("syncS2C") {[weak self] data, ack in
            let isSynced = data[0] as! Bool
            self!.state.modes.syncMode = isSynced
        }
        socket.on("playerLeft") {[weak self] data, ack in
            let playerID = data[0] as! String
            self!.state.removePlayer(playerID: playerID)
            
        }
        socket.on("newPlayer") {[weak self] data, ack in
            let player = data[0] as! [String: Any]
            self!.state.addPlayer(playerInfo: player)
            
        }
        
    }
    
    func updateInput(at loc: TileLoc, to new: TileInput) {
        socket.emit("onInputC2S", ["loc": loc.socketRepresentation(), "tileInput": new.socketRepresentation()])
    }
    func updateFocusedTile(to newTile: TileLoc) {
        socket.emit("focusedChangeC2S", newTile.socketRepresentation())
        
    }
    func updateCurrentTile(to newTile: TileLoc) {
        socket.emit("tileChangeC2S", newTile.socketRepresentation())
    }
    func updateCurrentWord(to newWord: [TileLoc]) {
        socket.emit("wordChangeC2S", serialize1DArray(arr: newWord))
    }
    func updateSync(to isSynced: Bool) {
        socket.emit("syncC2S", isSynced)
    }
    deinit {
        print("Socket deinitialized!")
    }
    
    
    
}
