//
//  CrosswordCore.swift
//  crossword
//
//  Created by Mason Zhang on 5/3/20.
//  Copyright © 2020 mason. All rights reserved.
//
class CrosswordCore {
    var id: CrosswordID
    var state: CrosswordState
    var scheme: CrosswordScheme
    var server: SocketBridge?
    
    init(id: CrosswordID, user: User) {
        self.id = id
        scheme = CrosswordBuilder.buildCrosswordScheme(for: id)
        state = CrosswordBuilder.newCrosswordState(from: scheme)
        CrosswordIO.retrieveCrosswordState(user: user, id: id) { stored in
            guard var stored = stored else {
                return
            }
            //fake MP tag
            stored.multiplayerID = "masonzhang21-nyt-11-01-1933"
            print("%COMP", stored.percentCompleted, stored.secondsElapsed)
            if let multiplayerID = stored.multiplayerID {
                self.server = SocketBridge(username: user.uid, multiplayerID: multiplayerID, state: self.state)
                self.state.modes.multiplayerMode = true
            } else {
                //Singleplayer game
                let storedState = CrosswordBuilder.buildCrosswordState(from: stored)
                self.state.input = storedState.input
                self.state.modes.readyMode = true
            }
        }
    }
    /**
     Returns the first empty tile in a list of tiles, or the first tile if all tiles are filled. Input is usually currentWord.
     */
    func firstEmptyTile(in word: [TileLoc]) -> TileLoc {
        for tile in word {
            if state.input[tile.row][tile.col]!.text == "" {
                return tile
            }
        }
        return word.first!
    }
    /**
     Returns all tiles in the same word as the lookup tile (including the lookup tile) in the order they appear in the word
     
     - Parameters:
     - lookupTile: The tile whose sibling tiles (tiles in the same word as it) we're searching for
     - dir: Direction for the search
     
     - Returns: An array of tuples corresponding to the locations of all tiles in the same word as the lookup tile
     */
    func tilesInSameWord(as lookupTile: TileLoc, dir: Direction) -> [TileLoc] {
        var tiles: [TileLoc] = []
        switch dir {
        case .across:
            let row = lookupTile.row
            var firstTileInWord: TileLoc = TileLoc(row: row, col: 0)
            for i in (0...lookupTile.col).reversed() {
                let ithTile = scheme.grid[row][i]
                if ithTile == nil {
                    firstTileInWord = TileLoc(row: row, col: i + 1)
                    break
                }
            }
            for i in firstTileInWord.col..<scheme.numCols {
                let ithTile = scheme.grid[row][i]
                if ithTile == nil {
                    break
                } else {
                    tiles.append(TileLoc(row: row, col: i))
                }
            }
        case .down:
            let col = lookupTile.col
            var firstTileInWord: TileLoc = TileLoc(row: 0, col: col)
            for i in (0...lookupTile.row).reversed() {
                let ithTile = scheme.grid[i][col]
                if ithTile == nil {
                    firstTileInWord = TileLoc(row: i + 1, col: col)
                    break
                }
            }
            for i in firstTileInWord.row..<scheme.numCols {
                let ithTile = scheme.grid[i][col]
                if ithTile == nil {
                    break
                } else {
                    tiles.append(TileLoc(row: i, col: col))
                }
            }
        }
        return tiles
    }
    
    /**
     Finds the location of the tile containing the specified gridnum
     
     - Parameters:
     - num: The gridnum
     
     - Returns: The TileLoc of the specified gridnum
     */
    func gridnumLoc(of num: Int) -> TileLoc? {
        for row in 0..<scheme.numRows {
            if let col = scheme.gridnums[row].firstIndex(of: num) {
                return TileLoc(row: row, col: col)
            }
        }
        return nil
    }
    
    func toggleClueMode() {
        state.modes.clueMode.toggle()
        if state.modes.clueMode {
            state.active = false
        } else {
            state.active = true
        }
    }
    
    
    func deactivateBoard() {
        updateFocusedTile(to: state.currentTile)
        state.active = false
        }
    
    func activateBoard() {
        updateFocusedTile(to: nil)
        state.active = true
    }
    
    /**
     Changes the direction in CrosswordState and recalculates the current word
     */
    func flipDirection() {
        switch state.direction {
        case .across:
            state.direction = .down
        case .down:
            state.direction = .across
        }
        updateCurrentWord(to: tilesInSameWord(as: state.currentTile, dir: state.direction))
    }
    
    /**
     Changes focus to a certain tile
     
     Parameters:
     - loc: The tile to focus
     */
    func focus(tile: TileLoc) {
        updateFocusedTile(to: tile)
        updateCurrentWord(to: tilesInSameWord(as: tile, dir: state.direction))
    }
    
    func updateFocusedTile(to newTile: TileLoc?) {
        if newTile != nil && state.modes.multiplayerMode {
            server!.updateCurrentTile(to: newTile!)
        } else {
            state.focusedTile = newTile
        }
    }
    
    //----- MULTIPLAYER FUNCTIONS -----
    func updateInput(at loc: TileLoc, to newGuess: TileInput) {
        if state.modes.multiplayerMode {
            server!.updateInput(at: loc, to: newGuess)
        } else {
            state.input[loc.row][loc.col] = newGuess
        }
    }
    func updateInputConfidence(at loc: TileLoc, to newConfidence: Font) {
        let inputText = state.input[loc.row][loc.col]!.text
        let newGuess = TileInput(text: inputText, font: newConfidence)
        if state.modes.multiplayerMode {
            server!.updateInput(at: loc, to: newGuess)
        } else {
            state.input[loc.row][loc.col] = newGuess
        }
    }
    func updateCurrentTile(to tile: TileLoc) {
        if state.modes.multiplayerMode {
            server!.updateCurrentTile(to: tile)
        } else {
            state.currentTile = tile
        }
    }
    func updateCurrentWord(to word: [TileLoc]) {
        if state.modes.multiplayerMode {
            server!.updateCurrentWord(to: word)
        } else {
            state.currentWord = word
        }
    }
    func updateSyncMode(to isSynced: Bool) {
        if state.modes.multiplayerMode {
            server!.updateSync(to: isSynced)
        } else {
            //this should never execute
            state.modes.syncMode = isSynced
        }
    }
}
