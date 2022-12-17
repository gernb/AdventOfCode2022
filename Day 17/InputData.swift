//
//  InputData.swift
//  Day 17
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

import Foundation

enum InputData: String, CaseIterable {
    static let day = 17

    case example, challenge

    var data: Array<Character> {
        Array(self.lines[0])
    }

    var lines: [String] {
        switch self {

        case .example: return """
>>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>
""".components(separatedBy: .newlines)

        case .challenge:
            return try! String(contentsOfFile: ("~/Desktop/input.txt" as NSString).expandingTildeInPath)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: .newlines)

        }
    }
}
