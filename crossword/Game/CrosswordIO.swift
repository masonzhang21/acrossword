//
//  CrosswordIO.swift
//  crossword
//
//  Created by Mason Zhang on 7/3/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SwiftyJSON
import Firebase
import FirebaseFirestoreSwift

class CrosswordIO {
    static func retrieveJSONFromDisk(id: CrosswordID) -> JSON? {
        let group = DispatchGroup()
        group.enter()
        let directory = id.newspaper + "/" + id.year + "/" + id.month
        guard let path = Bundle.main.path(forResource: id.day, ofType: "json", inDirectory: directory) else {
            return nil
        }
        guard let data = NSData(contentsOfFile: path) else {
            return nil
        }
        guard let json = try? JSON(data: data as Data) else {
            return nil
        }
        group.leave()

        group.wait()
        return json
    }
    
    static func storeCrosswordState(user: User, state: CrosswordState, id: CrosswordID) {
        //only write if current 'last edited' > stored 'last edited' (given that stored 'last edited' exists
        var input: [Int : [TileInput?]] = [:]
        for (index, row) in state.input.enumerated() {
            input[index] = row
        }
        var numFilled: Int = 0
        var numSquares: Int = 0
        for row in state.input {
            for tile in row {
                if let tile = tile {
                    if tile.text != "" {
                        numFilled+=1
                    }
                    numSquares+=1
                }
            }
        }
        let percentCompleted: Int = Int(Double(numFilled) / Double(numSquares) * 100)
        let storableState = StoredCrossword(input: input, id: id, timeSinceLastChange: state.lastEdit, percentCompleted: percentCompleted, secondsElapsed: state.secondsElapsed)
        var err : String
        do {
            try Firestore.firestore().collection("users").document(user.uid)
                .collection("crosswords").document(id.idString).setData(from: storableState)
        } catch {
            err = "Write failed"
        }
    }
    
    static func retrieveCrosswordState(user: User, id: CrosswordID, onComplete: @escaping (StoredCrossword?) -> Void) {
        Firestore.firestore().collection("users").document(user.uid)
        .collection("crosswords").document(id.idString).getDocument { (document, error) in
            // Construct a Result type to encapsulate deserialization errors or
            // successful deserialization. Note that if there is no error thrown
            // the value may still be `nil`, indicating a successful deserialization
            // of a value that does not exist.
            //
            // There are thus three cases to handle, which Swift lets us describe
            // nicely with built-in sum types:
            //
            //      Result
            //        /\
            //   Error  Optional<StoredCrossword>
            //               /\
            //            Nil  StoredCrossword
            let result = Result {
              try document?.data(as: StoredCrossword.self)
            }
            switch result {
            case .success(let stored):
                onComplete(stored)
            case .failure(let error):
                // A `StoredCrossword` value could not be initialized from the DocumentSnapshot.
                print("Error decoding StoredCrossword: \(error)")
            }
        }
    }
}
