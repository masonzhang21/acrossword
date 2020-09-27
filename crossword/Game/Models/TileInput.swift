//
//  TileInput.swift
//  crossword
//
//  Created by Mason Zhang on 7/22/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import SocketIO

struct TileInput: Equatable, Codable, SocketData {
    var text: String = ""
    var font: Font = .normal
    
    init(serializedTileInput: [String: Any]) {
        text = serializedTileInput["text"] as! String
        font = Font(rawValue: serializedTileInput["font"] as! Int)!
    }

    init(text: String, font: Font) {
        self.text = text
        self.font = font
    }
    
    func socketRepresentation() -> SocketData {
        return ["text": text, "font": Font.toRawValue(font)]
    }
}

enum Font: Int, Codable {
    case correct = 0
    case incorrect = 1
    case pencil = 2
    case normal = 3
}

/*extension Font: Codable {
    enum Key: CodingKey {
        case rawValue
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            self = .correct
        case 1:
            self = .incorrect
        case 2:
            self = .pencil
        case 3:
            self = .normal
        default:
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .correct:
            try container.encode(0, forKey: .rawValue)
        case .incorrect:
            try container.encode(1, forKey: .rawValue)
        case .pencil:
            try container.encode(2, forKey: .rawValue)
        case .normal:
            try container.encode(3, forKey: .rawValue)
            
        }
    }
}*/

extension Font: SocketData {
    static func toRawValue(_ font: Font) -> Int {
        switch font {
        case .correct:
            return 0
        case .incorrect:
            return 1
        case .pencil:
            return 2
        case .normal:
            return 3
        }
    }
    static func toEnum(_ rawValue: Int) -> Font {
        switch rawValue {
        case 0:
            return .correct
        case 1:
            return .incorrect
        case 2:
            return .pencil
        case 3:
            return .normal
        default:
            return .normal
        }
    }
    
}
