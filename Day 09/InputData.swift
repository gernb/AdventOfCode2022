//
//  InputData.swift
//  Day 09
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

import Foundation

enum InputData: String, CaseIterable {
    case example, example2
    case challenge

    var data: [String] {
        switch self {

        case .example: return """
R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
""".components(separatedBy: .newlines)

        case .example2: return """
R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
""".components(separatedBy: .newlines)

        case .challenge:
            return try! String(contentsOfFile: ("~/Desktop/input.txt" as NSString).expandingTildeInPath)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: .newlines)

        }
    }
}
