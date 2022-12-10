//
//  InputData.swift
//  Day 08
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

import Foundation

enum InputData: String, CaseIterable {
    case example, challenge

    var data: [[Int]] {
        switch self {

        case .example: return """
30373
25512
65332
33549
35390
""".components(separatedBy: .newlines)
   .map { $0.compactMap{ Int(String($0)) } }

        case .challenge:
            return try! String(contentsOfFile: ("~/Desktop/input.txt" as NSString).expandingTildeInPath)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: .newlines)
                .map { $0.compactMap{ Int(String($0)) } }

        }
    }
}
