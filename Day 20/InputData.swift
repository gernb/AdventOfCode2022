//
//  InputData.swift
//  Day 20
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

import Foundation

enum InputData: String, CaseIterable {
    static let day = 20

    case example, challenge

    var numbers: [Int] {
        let values = self.lines.compactMap(Int.init)
        assert(values.count == lines.count)
        return values
    }

    var lines: [String] {
        switch self {

        case .example: return """
1
2
-3
3
-2
0
4
""".components(separatedBy: .newlines)

        case .challenge:
            return try! String(contentsOfFile: ("~/Desktop/input.txt" as NSString).expandingTildeInPath)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: .newlines)

        }
    }
}
